// SPDX-License-Identifier: MIT 
pragma solidity ^0.6.0;


contract Mapping {
    //1
    mapping(uint => string) public names;
    constructor() public {
        names[1] = "Khandokar";
        names[2] = "Rifat";
        names[3] = "Muhtasim";
    }


    //2
    uint public booksCount = 0;
    mapping(uint => Book) public books;

    struct Book{
        uint books_id;
        string title;
        string author;
    }
    function addBook(string memory _title, string memory _author) public {
        booksCount += 1;
        books[booksCount] = Book(booksCount, _title, _author);
    }


    //3
    mapping(address => mapping(uint => MyBook)) public myBooks;
    struct MyBook{
        uint id;
        address myAddress;
        string title;
        string author;
    }

    function addMyBook(uint _id, string memory _title, string memory _author) public {
        myBooks[msg.sender][_id] = MyBook(_id, msg.sender, _title, _author);
    }
}