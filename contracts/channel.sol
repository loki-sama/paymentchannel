pragma solidity ^0.4.19;
import "./SafeMath.sol";


contract Channel {
    using SafeMath for uint256;

    
    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    /**
    * @dev Throws if called by any account other than the person2.
    */
    modifier onlyPerson2() {
        require(msg.sender == person2);
        _;
    }

    /**
    * @dev Throws if called by any account other than the person2.
    */
    modifier onlyOwnerOrPerson2() {
        require(msg.sender == person2 || msg.sender == owner);
        _;
    }
    //2 persons the payment channel is open with
    address owner; 
    address person2;

    mapping(address => uint256) deposit;
    uint256 totalDeposit; 
    uint channelTimeout;
    
    //create channel 
    function Channel (address _owner, address _person2, uint _channelTimeout) public {
        owner = _owner;
        person2 = _person2;
        channelTimeout = _channelTimeout;
    }

    //for factory we init with extra methode
    function depositFund() public onlyOwnerOrPerson2 payable {
        require(msg.value > 0);
        totalDeposit = totalDeposit.add(msg.value);
        deposit[msg.sender] = deposit[msg.sender].add(msg.value);
    }


}