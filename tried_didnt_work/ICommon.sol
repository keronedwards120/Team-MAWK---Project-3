pragma experimental ABIEncoderV2;
pragma solidity >=0.5.0;

interface ICommon{
    struct Item{
        address payable owner;
        string uri;
        uint value;
    }
}