pragma solidity ^0.4.18;

import './RomadDefenseTokenCommonSale.sol';
import './StagedCrowdsale.sol';

contract ICO is StagedCrowdsale, RomadDefenseTokenCommonSale {

  address public teamTokensWallet;
  address public bountyTokensWallet;
  uint public teamTokensPercent;
  uint public bountyTokensPercent;
  uint public USDHardcap;
  uint public USDPrice; // usd per token
  uint public ETHtoUSD; // usd per eth

  function setTeamTokensPercent(uint newTeamTokensPercent) public onlyOwner {
    teamTokensPercent = newTeamTokensPercent;
  }

  function setBountyTokensPercent(uint newBountyTokensPercent) public onlyOwner {
    bountyTokensPercent = newBountyTokensPercent;
  }

  function setTeamTokensWallet(address newTeamTokensWallet) public onlyOwner {
    teamTokensWallet = newTeamTokensWallet;
  }

  function setBountyTokensWallet(address newBountyTokensWallet) public onlyOwner {
    bountyTokensWallet = newBountyTokensWallet;
  }

  // three digits
  function setUSDHardcap(uint newUSDHardcap) public onlyOwner {
    USDHardcap = newUSDHardcap;
  }

  function updateHardcap() internal {
    hardcap = USDHardcap.mul(1 ether).div(ETHtoUSD);
  }

  function setUSDPrice(uint newUSDPrice) public onlyDirectMintAgentOrOwner {
    USDPrice = newUSDPrice;
  }

  function updatePrice() internal {
    price = ETHtoUSD.mul(1 ether).div(USDPrice);
  }

  function setETHtoUSD(uint newETHtoUSD) public onlyDirectMintAgentOrOwner {
    ETHtoUSD = newETHtoUSD;
    updateHardcap();
    updatePrice();
  }

  function calculateTokens(uint _invested) internal returns(uint) {
    uint milestoneIndex = currentMilestone(start);
    Milestone storage milestone = milestones[milestoneIndex];
    require(_invested >= milestone.minInvestedLimit);
    uint tokens = _invested.mul(price).div(1 ether);
    if (milestone.bonus > 0) {
      tokens = tokens.add(tokens.mul(milestone.bonus).div(percentRate));
    }
    return tokens;
  }

  function finish() public onlyOwner {
    uint summaryTokensPercent = bountyTokensPercent.add(teamTokensPercent);
    uint mintedTokens = token.totalSupply();
    uint allTokens = mintedTokens.mul(percentRate).div(percentRate.sub(summaryTokensPercent));
    uint foundersTokens = allTokens.mul(teamTokensPercent).div(percentRate);
    uint bountyTokens = allTokens.mul(bountyTokensPercent).div(percentRate);
    mintTokens(teamTokensWallet, foundersTokens);
    mintTokens(bountyTokensWallet, bountyTokens);
    token.finishMinting();
  }

  function endSaleDate() public view returns(uint) {
    return lastSaleDate(start);
  }

}
