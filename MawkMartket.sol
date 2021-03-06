pragma solidity >=0.4.22 <=0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721Full.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/ownership/Ownable.sol";
import "./MawkAuction.sol";

contract MawkMarket is ERC721Full, Ownable {

    constructor() ERC721Full("MartianMarket", "MARS") public {}

    using Counters for Counters.Counter;

    Counters.Counter token_ids;

    address payable foundation_address = msg.sender;
    mapping(uint => MawkAuction) public auctions;

    modifier landRegistered(uint token_id) {
        require(_exists(token_id), "Land not registered!");
        _;
    }
    
    mapping(uint => address) public token_owner;
    
    //event RegisterItem (uint token_id, address owner, string uri);
    event Verify(uint token_id);


    function registerLand(string memory uri) public payable {
        token_ids.increment();
        uint token_id = token_ids.current();
        _mint(msg.sender, token_id);
        _setTokenURI(token_id, uri);
        createAuction(token_id, msg.sender);
        token_owner[token_id]=msg.sender;
        //emit RegisterItem(token_id, msg.sender, uri);
    }

    function createAuction(uint token_id, address payable beneficiary) public  {
        auctions[token_id] = new MawkAuction(beneficiary);
    }

    function endAuction(uint token_id) public onlyOwner landRegistered(token_id) {
        MawkAuction auction = auctions[token_id];
        auction.auctionEnd();
        //safeTransferFrom(token_owner[token_id], auction.highestBidder(), token_id);
        token_owner[token_id]=auction.highestBidder();
    }
    
    function checkOwner(uint token_id) public view returns(address){
        return token_owner[token_id];
    }

    function address_owner() public view returns(address){
        return foundation_address;
    }

    function auctionEnded(uint token_id) public view returns(bool) {
        MawkAuction auction = auctions[token_id];
        return auction.ended();
    }

    function highestBid(uint token_id) public view landRegistered(token_id) returns(uint) {
        MawkAuction auction = auctions[token_id];
        return auction.highestBid();
    }

    function pendingReturn(uint token_id, address sender) public view landRegistered(token_id) returns(uint) {
        MawkAuction auction = auctions[token_id];
        return auction.pendingReturn(sender);
    }

    function bid(uint token_id) public payable landRegistered(token_id) {
        MawkAuction auction = auctions[token_id];
        auction.bid.value(msg.value)(msg.sender);
    }
    
    function withdraw (uint token_id) public {
        MawkAuction auction = auctions[token_id];
        auction.withdraw(msg.sender);
    }
    
    function verify (uint token_id) public onlyOwner {
        MawkAuction auction = auctions[token_id];
        auction.verify();
        emit Verify(token_id);
    }
    
    function verifycheck (uint token_id) public view returns (bool){
        MawkAuction auction = auctions[token_id];
        return auction.verifycheck();
    }
}
