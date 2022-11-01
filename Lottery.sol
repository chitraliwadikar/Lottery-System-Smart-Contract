//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Lottery
{
    //Manager stores address of the account who will pick the winner. Manager cannot participate in the lottery.
    address payable public Manager;
    address payable public winnerAddress;
    uint public PlayerCount=0;
    //Players is the array that stores address of all the participants.
    address payable[] public Players;

    constructor()
    {
        //The msg.sender is the address that has called or initiated a function or created a transaction (Manager in this case).
        Manager = payable(msg.sender); 
    }
    
    //Below function ensures unique users have entered
    function alreadyEntered() view private returns(bool) 
    {
        for(uint i=0; i<Players.length; i++)
        {
            if(Players[i]==msg.sender)
               return true;
        }
        return false;
    }

    //Below function checks the constriants and pushes valid player into the array
    function Participate() payable public
    {
        /*
         We need the contract to recieve funds in the form of ether. If ether is recieved successfully, i.e. the lottery is bought,
         add the participant in the array.
        */
        require(msg.sender != Manager, "Sorry! Manager cannot participate.");
        require(alreadyEntered() == false, "Sorry! You can enter the lottery only once.");
        require(msg.value >= 1 ether, "Please pay the minimum amount [1 ether] ");
        PlayerCount ++;
        Players.push(payable(msg.sender));
    } 

    //Below function returns a randomly generated uint value based on the participants list
    function random() view private returns(uint)
    {
        /*
        Players.length: Length of the participants list
        block.difficulty: Difficulty of the block to be mined at the moment
        block.number: Current block number
        abi.encodePacked(arg): Used to simply concatenate the arguments into one without spaces
        sha256: Hashing algorithm
        As all the above factors keep changing, the randomness increases, hence it is used to 
        generate a random number which can't be predicted.
        */
        return uint(sha256(abi.encodePacked(block.difficulty, block.number, Players.length)));
    }

    //Below function is used to pick the winner
    function pickWinner() public
    {
        require(msg.sender == Manager, "Only manager can pick the winner !");
        require(Players.length >=2 , "Atleast two players required for the Lottery!");
        uint index = random()%Players.length; // finding index of the winner
        winnerAddress = Players[index];
        sendReward(winnerAddress);
    }

    //Below function calculates the manager's incentive and ether's received by the winner and tranfers it to respective accounts.
    function sendReward(address payable winner) internal
    {
        uint bal = Balance();
        uint div = 100;
        uint mul = 10;
        uint incentive = bal / div * mul; //calculates the incentive manager gets(10%)
        bal = bal - incentive;
        winner.transfer(bal);
        Manager.transfer(incentive);
        //After the reward has been given, reset the participant list for next lottery session
        Players = new address payable[](0); 
        //Reset player count to 0
        PlayerCount=0;
    }

    //Below function is used to return address of all the players 
    function getPlayers() view public returns(address payable[] memory)
    {
        return Players;
    }

    //Below function is used to know the amount of ether that are present in contract's fund
    function Balance() view public returns(uint)
    {
        return address(this).balance;
    }

}
