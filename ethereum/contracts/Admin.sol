pragma solidity ^0.4.24;

contract UserFactory {
    address[] public deployedUsers;

    function createUser(uint minimum) public {
        address newUser = new User(minimum, msg.sender);
        deployedUsers.push(newUser);
    }

    function getDeployedUsers() public view returns (address[]){
        return deployedUsers;
    }
}

contract User {

    //User description
    struct UserDetail {
        string fName;
        string lName;
        uint value;
        address userAddress;
        bool verified;
        uint approvalCount;
        mapping (address => bool) approvals;
    }

    address public manager;
    uint public minimumContribution;

    UserDetail[] public userdetails;

    mapping(address => bool) public approvers;
    uint public approversCount;

    modifier restricted(){
        require(msg.sender == manager);
        _;
    }

    constructor (uint minimum ,address creater) public {
        manager = creater;
        minimumContribution = minimum;
    }

    function contribute() public payable {
        require(msg.value > minimumContribution);

        approvers[msg.sender] = true;
        approversCount++;
    }

    function createUser(string fName, string lName, uint value ,address userAddress) public restricted {
        UserDetail memory newUser = UserDetail({
           fName: fName,
           lName: lName,
           value: value,
           userAddress: userAddress,
           verified: false,
           approvalCount: 0
        });

        userdetails.push(newUser);
    }

    function approveUser(uint index) public {
        UserDetail storage userdetail = userdetails[index];

        require(approvers[msg.sender]);

        require(!userdetail.approvals[msg.sender]);

        userdetail.approvals[msg.sender] = true;
        userdetail.approvalCount++;
    }

    function finalizeUser(uint index) public restricted {
        UserDetail storage userdetail = userdetails[index];

        require(userdetail.approvalCount > (approversCount / 2));
        require(!userdetail.verified);

        userdetail.userAddress.transfer(userdetail.value);
        userdetail.verified = true;
    }
}
