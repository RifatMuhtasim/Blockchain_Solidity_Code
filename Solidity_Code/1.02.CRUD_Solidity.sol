// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract CRUD_Example {
    uint256 id;

    constructor(){
        id = 0;
    }

    struct Item {
        uint256 id;
        string name;
        uint256 age;
    }
    Item[] Items;


    function create_item(string memory _name, uint256 _age) public {
        Item memory newItem = Item({ id: id, name: _name, age: _age});
        Items.push(newItem);
        id += 1;
    }

    function get_item_with_id(uint256 _id) public view returns(Item memory){
        for(uint256 i=0; i<Items.length; i++){
            if(Items[i].id == _id){
                return Items[_id];
            }
        }
        revert("Items is not found");
    }

    function update_item(uint256 _id, string memory _name, uint256 _age) public {
        for(uint256 i=0; i < Items.length; i++){
            if(Items[i].id == _id){
                Items[i].name = _name;
                Items[i].age = _age;
                return;
            } 
        }
        revert("Items is not found");
    }

    function delete_item(uint256 _id) public {
        for (uint256 i=0; i<Items.length; i++){
            if(Items[i].id == _id){
                // Remove the item by swapping with the last item and then reducing the array length
                Items[i] = Items[Items.length - 1];
                Items.pop();
                return ;
            }
        }
        revert("Items not found");
    }

}
