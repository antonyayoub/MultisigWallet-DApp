// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract MultisigWallet {
    address public owner;
    address[] public members;

    mapping(address => uint) public balanceOf;

    // fire events to notify other members that a function has been called
    event MemberAdded(address addedByMember, address memberAdded, uint time);
    event MemberRemoved(address removedBy, address ownerRemoved, uint time);
    event Deposited(address sender, uint amount, uint time);
    event Withdrawal(address sender, uint amount, uint time);

    constructor() {
        owner = msg.sender;
        members.push(owner);
    }

    modifier onlyMember() {
        bool isMember = false;
        for (uint i = 0; i < members.length; i++) {
            if (members[i] == msg.sender) {
                isMember = true;
                break;
            }
        }
        require(isMember, "Only members can call this function!");
        _;
    }

    function addMember(address newMember) public onlyMember {
        for (uint i = 0; i < members.length; i++) {
            if (members[i] == newMember) {
                revert("Member already exists!");
            }
        }
        members.push(newMember);
        emit MemberAdded(msg.sender, newMember, block.timestamp);
    }

    function removeMember(address oldMember) public onlyMember {
        bool memberFound = false;
        uint memberIndex;
        for (uint i = 0; i < members.length; i++) {
            if (members[i] == oldMember) {
                memberFound = true;
                memberIndex = i;
                break;
            }
        }
        require(memberFound, "Member not found!");
        members[memberIndex] = members[members.length - 1];
        members.pop();
        emit MemberRemoved(msg.sender, oldMember, block.timestamp);
    }

    function deposit() public payable onlyMember {
        require(balanceOf[msg.sender] >= 0, "Amount must be greater than 0!");
        balanceOf[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value, block.timestamp);
    }

    function withdraw(uint amount) public onlyMember {
        require(balanceOf[msg.sender] >= amount, "Not enough balance!");
        balanceOf[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount, block.timestamp);
    }

    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
}
