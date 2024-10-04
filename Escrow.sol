// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Escrow {
    address public buyer;
    address public seller;
    address public escrowAgent;

    bool public fundsReleased;

    uint public amount;

    constructor(address _buyer, address _seller, uint _amount) {
        escrowAgent = msg.sender; 
        buyer = _buyer;
        seller = _seller;
        amount = _amount;
        fundsReleased = false;
    }

    modifier onlyEscrowAgent() {
        require(msg.sender == escrowAgent, "Only the escrow agent can call this function.");
        _;
    }

    function deposit() external payable {
        require(msg.sender == buyer, "Only the buyer can deposit funds.");
        require(msg.value == amount, "Incorrect deposit amount.");
        require(address(this).balance == amount, "Contract balance must match the required amount.");
    }

    function releaseFunds() external onlyEscrowAgent {
        require(address(this).balance == amount, "Insufficient funds in the contract.");
        require(fundsReleased == false, "Funds have already been released.");
        
        fundsReleased = true;
        payable(seller).transfer(amount); 
    }

    function refundBuyer() external onlyEscrowAgent {
        require(fundsReleased == false, "Funds have already been released.");
        require(address(this).balance == amount, "Contract must hold the funds.");
        
        fundsReleased = true;
        payable(buyer).transfer(amount);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
