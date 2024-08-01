// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/eas-contracts/contracts/IEAS.sol";

/**
 * @title Bounty modified from PaymentSplitter
 * @dev This contract can be used when payments need to be received by a group
 * of people and split proportionately to some number of shares they own.
 */
contract Bounty {
    uint256 public number;

    address easAddress;
    

    event PayeeAdded(address account, uint256 shares);
    event PaymentReleased(address to, uint256 amount);
    event PaymentReceived(address from, uint256 amount);

    uint256 private _totalShares;
    uint256 private _totalReleased;

    mapping(address => uint256) private _shares;
    mapping(address => uint256) private _released;
    address[] private _payees;

  /**
   * @dev Constructor
   */
  constructor() payable {
    // TODO at deployment time, set the EAS contract address
    easAddress = 0x4200000000000000000000000000000000000021;
  }

  /**
   * @dev payable fallback
   */
  receive() external payable {
    emit PaymentReceived(msg.sender, msg.value);
  }

  /**
   * @return the total shares of the contract.
   */
  function totalShares() public view returns(uint256) {
    return _totalShares;
  }

  /**
   * @return the total amount already released.
   */
  function totalReleased() public view returns(uint256) {
    return _totalReleased;
  }

  /**
   * @return the shares of an account.
   */
  function shares(address account) public view returns(uint256) {
    return _shares[account];
  }

  /**
   * @return the amount already released to an account.
   */
  function released(address account) public view returns(uint256) {
    return _released[account];
  }

  /**
   * @return the address of a payee.
   */
  function payee(uint256 index) public view returns(address) {
    return _payees[index];
  }

  /**
   * @dev Release one of the payee's proportional payment.
   * @param account Whose payments will be released.
   */
  function release(address payable account) public {
    require(_shares[account] > 0);

    uint256 totalReceived = address(this).balance + (_totalReleased);
    uint256 payment = totalReceived * _shares[account] / _totalShares - _released[account];

    require(payment != 0);

    _released[account] = _released[account] + payment;
    _totalReleased = _totalReleased + payment;

    account.transfer(payment);
    emit PaymentReleased(account, payment);
  }

  /**
   * @dev Add a new payee to the contract.
   * @param account The address of the payee to add.
   */
  function addPayee(address account, bytes32 attest_uid) public {
    require(account != address(0));
    require(_shares[account] == 0);
    uint8 share = 1;
    IEAS eas = IEAS(easAddress);

    // require(eas.getAttestation(attest_uid).recipient == account, "Attestation receipent incorrect");

    _payees.push(account);
    _shares[account] += share;
    _totalShares = _totalShares + share;
    emit PayeeAdded(account, share);
  }
}
