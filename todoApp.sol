// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract TodoList {
    struct Todo {
        string text;
        bool completed;
    }

    Todo[] public todos;

    function get(uint _index) public view returns(Todo memory) {
        return todos[_index];
    }

    function create(string calldata _text) public {
        todos.push(Todo(_text, false));
    }

    function toggleCompleted(uint _index) public {
        todos[_index].completed = !todos[_index].completed;
    }

    function updateText(uint _index, string calldata _str) public {
        todos[_index].text = _str;
    }

}