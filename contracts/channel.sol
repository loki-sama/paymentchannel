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
    uint256 ownerBalance;  
    uint channelTimeout;
    uint closingTime;

    uint msgNumber;
    bool closing;
    bool started;


    //create channel 
    function Channel (address _owner, address _person2, uint _channelTimeout) public {
        owner = _owner;
        person2 = _person2;
        channelTimeout = _channelTimeout;
        msgNumber = 0;
        closing = false;
        started = false;
    }

    //for factory we init with extra methode
    function depositFund(bool _started) public onlyOwnerOrPerson2 payable {
        require(!started);
        require(msg.value > 0);
        //can only start when deposit money not perfect
        started = _started;
        totalDeposit = totalDeposit.add(msg.value);
        deposit[msg.sender] = deposit[msg.sender].add(msg.value);

    }

    function CloseChannel(bytes32 h, uint8 v, bytes32 r, bytes32 s, uint8 vperson2, bytes32 rperson2, bytes32 sperson2, uint _msgNumber, uint value)  public onlyOwnerOrPerson2 {
        require(started);
        require(!closing || closingTime.add(channelTimeout) < now );

		address signerOwner;
        address signerPerson2;
		bytes32 proof;

		// get signer from signature
		signerOwner = ecrecover(h, v, r, s);

		if (signerOwner != owner) throw;

		// get signer from signature
		signerPerson2 = ecrecover(h, vperson2, rperson2, sperson2);
		// signature is invalid, throw
		if ( signerPerson2 != person2) throw;

		proof = sha3(this, msgNumber, value);

		// signature is valid but doesn't match the data provided
		if (proof != h) throw;


        if(_msgNumber <= msgNumber && msgNumber != 0 ) throw;
        if(msgNumber == 0 && closing ) throw;

        
        msgNumber = _msgNumber;
        closingTime = now;
        closing = true;
        ownerBalance = value;
	}


    function payout() external onlyOwnerOrPerson2 {
        require(closing && closingTime.add(channelTimeout) < now);
		owner.transfer(ownerBalance);
		person2.transfer(totalDeposit - ownerBalance);


	}

}