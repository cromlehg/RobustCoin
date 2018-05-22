pragma solidity ^0.4.18;

import "./CommonSale.sol";
import "./NextSaleAgentFeature.sol";

contract PreICO is CommonSale, NextSaleAgentFeature {

  bool public softcapReached;
  bool public refundOn;
  uint public softcap;
  uint public USDSoftcap;
  uint public constant devLimit = 19500000000000000000;
  address public constant devWallet = 0xEA15Adb66DC92a4BbCcC8Bf32fd25E2e86a2A770;

  // --------------------------------------------------------------------------
  // Common
  // --------------------------------------------------------------------------

  function setSoftcap(uint _softcap) public onlyOwner {
    softcap = _softcap;
  }

  function mintTokensByETH(address _to, uint _invested) internal returns(uint) {
    super.mintTokensByETH(_to, _invested);
    updateSoftcapState();
  }

  function withdraw() public {
    require(msg.sender == owner || msg.sender == devWallet);
    require(softcapReached);
    devWallet.transfer(devLimit);
    wallet.transfer(weiApproved.sub(devLimit));
  }

  function finish() public onlyOwner {
    if (updateRefundState()) {
      token.finishMinting();
    } else {
      withdraw();
      token.setSaleAgent(nextSaleAgent);
    }
  }

  function updateSoftcapState() internal {
    if (!softcapReached && weiApproved >= softcap) {
      softcapReached = true;
    }
  }

  function updateRefundState() internal returns(bool) {
    if (!softcapReached) {
      refundOn = true;
    }
    return refundOn;
  }

  function refund() public {
    if (refundOn) {
      require(balances[msg.sender] > 0);
      uint value = balances[msg.sender];
      balances[msg.sender] = 0;
      msg.sender.transfer(value);
    } else {
      super.refund();
    }
  }

  // --------------------------------------------------------------------------
  // KYC
  // --------------------------------------------------------------------------

  function approveCustomer(address _customer) public {
    super.approveCustomer(_customer);
    updateSoftcapState();
  }

  // --------------------------------------------------------------------------
  // USD conversion
  // --------------------------------------------------------------------------

  function setUSDSoftcap(uint _USDSoftcap) public onlyOwner {
    USDSoftcap = _USDSoftcap;
  }

  function updateSoftcap() internal {
    softcap = USDSoftcap.mul(1 ether).div(ETHtoUSD);
  }

  function setETHtoUSD(uint _ETHtoUSD) public onlyOwner {
    super.setETHtoUSD(_ETHtoUSD);
    updateSoftcap();
  }

}
