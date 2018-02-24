pragma solidity ^0.4.8;

contract OreOreCoin {
  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public totalSupply;
  mapping (address => uint256) public balanceOf;
  mapping (address => int8) public blackList;
  mapping (address => int8) public cashbackRate;
  address public owner;

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Blacklisted(address indexed target);
  event DeleteFromBlacklist(address indexed target);
  event RejectedPaymentToBlacklistedAddr(address indexed from, address indexed to, uint256 value);
  event RejectedPaymentFromBlacklistedAddr(address indexed from, address indexed to, uint256 value);
  event SetCashback(address indexed addr, int8 rate);
  event Cashback(address indexed from, address indexed to, uint256 value);

  function OreOreCoin(uint256 _supply, string _name, string _symbol, uint8 _decimals) public {
    balanceOf[msg.sender] = _supply;
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
    totalSupply = _supply;
    owner = msg.sender;
  }

  function blacklisting(address _addr) public onlyOwner() {
    blackList[_addr] = 1;
    Blacklisted(_addr);
  }

  function deleteFromBlacklist(address _addr) public onlyOwner() {
    blackList[_addr] = -1;
    DeleteFromBlacklist(_addr);
  }

  function setCashbackRate(int8 _rate) public {
    if (_rate < 1) {
      _rate = -1;
    } else if (_rate > 100) {
      _rate = 100;
    }
    cashbackRate[msg.sender] = _rate;
    if (_rate < 1) {
      _rate = 0;
    }
    SetCashback(msg.sender, _rate);
  }

  function transfer(address _to, uint256 _value) public {
    require(balanceOf[msg.sender] >= _value);
    require(balanceOf[_to] + _value >= balanceOf[_to]);

    if (blackList[msg.sender] > 0) {
      RejectedPaymentFromBlacklistedAddr(msg.sender, _to, _value);
    } else if (blackList[_to] > 0) {
      RejectedPaymentToBlacklistedAddr(msg.sender, _to, _value);
    } else {
      uint256 cashback = 0;
      if (cashbackRate[_to] > 0) cashback = _value / 100 * uint256(cashbackRate[_to]);

      balanceOf[msg.sender] -= (_value - cashback);
      balanceOf[_to] += (_value - cashback);

      Transfer(msg.sender, _to, _value);
      Cashback(_to, msg.sender, cashback);
    }
  }
}
