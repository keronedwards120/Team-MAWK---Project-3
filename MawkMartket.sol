pragma solidity >=0.4.22 <=0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721Full.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/ownership/Ownable.sol";
import "./MartianAuction.sol";

contract MartianMarket is ERC721Full, Ownable {

    constructor() ERC721Full("MartianMarket", "MARS") public {}

    using Counters for Counters.Counter;

    Counters.Counter token_ids;

    address payable foundation_address = msg.sender;

    mapping(uint => MartianAuction) public auctions;

    modifier landRegistered(uint token_id) {
        require(_exists(token_id), "Land not registered!");
        _;
    }
    
    //event RegisterItem (uint token_id, address owner, string uri);
    event Verify(uint token_id);

    function registerLand(string memory uri) public payable {
        token_ids.increment();
        uint token_id = token_ids.current();
        _mint(msg.sender, token_id);
        _setTokenURI(token_id, uri);
        createAuction(token_id);
        //emit RegisterItem(token_id, msg.sender, uri);
    }

    function createAuction(uint token_id) public  {
        auctions[token_id] = new MartianAuction(foundation_address);
    }

    function endAuction(uint token_id) public onlyOwner landRegistered(token_id) {
        MartianAuction auction = auctions[token_id];
        auction.auctionEnd();
        safeTransferFrom(owner(), auction.highestBidder(), token_id);
    }

    function auctionEnded(uint token_id) public view returns(bool) {
        MartianAuction auction = auctions[token_id];
        return auction.ended();
    }

    function highestBid(uint token_id) public view landRegistered(token_id) returns(uint) {
        MartianAuction auction = auctions[token_id];
        return auction.highestBid();
    }

    function pendingReturn(uint token_id, address sender) public view landRegistered(token_id) returns(uint) {
        MartianAuction auction = auctions[token_id];
        return auction.pendingReturn(sender);
    }

    function bid(uint token_id) public payable landRegistered(token_id) {
        MartianAuction auction = auctions[token_id];
        auction.bid.value(msg.value)(msg.sender);
    }
    
    function withdraw (uint token_id) public {
        MartianAuction auction = auctions[token_id];
        auction.withdraw(msg.sender);
    }
    
    function verify (uint token_id) public onlyOwner {
        MartianAuction auction = auctions[token_id];
        auction.verify();
        emit Verify(token_id);
    }
    
    function verifycheck (uint token_id) public view returns (bool){
        MartianAuction auction = auctions[token_id];
        return auction.verifycheck();
    }
}
