pragma solidity >=0.4.22 <=0.6.1;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721Full.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/ownership/Ownable.sol";
import "./Bidder.sol";
import "./Seller.sol";
import "./Interfaces/IMawkMarket.sol";
import "./Interfaces/ISeller.sol";
import "./Interfaces/ICommon.sol";

contract MawkMarket is IIMawkMarket, ERC721Full, Ownable {

    constructor() ERC721Full("MawkMarket", "MAWK") public {}

    using Counters for Counters.Counter;

    Counters.Counter token_ids;

    address payable foundation_address = msg.sender;

    mapping(uint => MawkAuction) public auctions;
    

    modifier landRegistered(uint token_id) {
        require(_exists(token_id), "Land not registered!");
        _;
    }

    function createAuction(uint token_id) public onlyOwner {
        auctions[token_id] = new MawkAuction(foundation_address);
    }

    //Move to seller contract
    /* function registerLand(string memory uri) public payable onlyOwner {
    //    token_ids.increment();
      //  uint token_id = token_ids.current();
        //_mint(foundation_address, token_id);
       // _setTokenURI(token_id, uri);
       // createAuction(token_id);
    }*/

    function endAuction(uint token_id) public onlyOwner landRegistered(token_id) {
        MawkAuction auction = auctions[token_id];
        auction.auctionEnd();
        safeTransferFrom(owner(), auction.highestBidder(), token_id);
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

}
