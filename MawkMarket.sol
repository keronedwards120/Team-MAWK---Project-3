pragma solidity >=0.5.0;

import "./OpenZeppelin/contracts/token/ERC721/ERC721Full.sol";
import "./OpenZeppelin/contracts/ownership/Ownable.sol";
import "./Bidder.sol";
import "./Seller.sol";
import "./IMawkMarket.sol";
import "./ISeller.sol";
import "./ICommon.sol";

contract MawkMarket is IMawkMarket,ICommon {
    constructor() ERC721Full("MawkMarket", "MAWK") public {}
    using Counters for Counters.Counter;

    Counters.Counter token_ids;
    Counters.Counter items_ids;
    address payable foundation_address = msg.sender;

    //mapping(uint => MawkAuction) public auctions;
    mapping(address => Seller) public seller_list;
    mapping(uint => Item) public item_list;
    mapping(address => Bidder) public bidder_list;


    modifier sellerRegistered(address payable _address) {
        require(seller_list[_address].isExit, "Seller not registered!");
        _;
    }

    modifier bidderRegistered(address payable _address) {
        require(bidder_list[_address].isExit, "Bidder not registered!");
        _;
    }

    function createAuction(uint token_id) public onlyOwner {
        auctions[token_id] = new MawkAuction(foundation_address);
    }

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

    // register seller
    function registerSeller(address payable _beneficiary) internal sellerRegistered(payable _beneficiary) {
        seller_lis _beneficiary] = new Seller(payable _beneficiary);
    }

    function registerBidder(address payable _beneficiary ) internal bidderRegistered(payable _beneficiary) {
        bidder_lis _beneficiary]=new Bidde _beneficiary);
    }

    // register item
    function registerItems(address payable owner,  string memory uri, uint value) public payable {
        item_id.increment();
        uint item_id = token_ids.current();
        items[item_id] = Item(owner, uri, value);
    }
}
