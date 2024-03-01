// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract local {
    address public owner;
   
    constructor() {
        owner = msg.sender;
    }


    struct Ocassion {
        string nameOfOcaasion;
        address payable ocassionManager;
        string description;
        uint256 maxNoOfTicekts;
        uint256 nthTicket;
        uint256 date;
        string location;
        uint256 price;
        string time;
        address[] attendants; //This will store all the ppl who are attending the event
    }

    mapping(uint256 => Ocassion) public noOfOcassions; //This will store all the occasions
    uint256 public nthOcassion;



    Ocassion[] public arr; //We will be pushing all the ocassions in this for accessing in the frontend

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }




    function getAddressList(uint256 id) public view returns (address[] memory) {
        Ocassion storage thisOcassion = noOfOcassions[id];

        return thisOcassion.attendants;
    }



    function addEvent(
        string memory _nameOfOcaasion,
        address payable  _ocassionManager,
        string memory _description,
        uint256 _maxNoOfTicekts,
        uint256 _date,
        string memory _loaction,
        uint256 _price,
        string memory _time
    ) public onlyOwner {
        Ocassion storage newOcassion = noOfOcassions[nthOcassion];
        newOcassion.description = _description;
        newOcassion.ocassionManager = _ocassionManager;
        newOcassion.nameOfOcaasion = _nameOfOcaasion;
        newOcassion.maxNoOfTicekts = _maxNoOfTicekts;
        newOcassion.date = _date;
        newOcassion.location = _loaction;
        newOcassion.price = _price;
        newOcassion.time = _time;

        nthOcassion++;
        arr.push(newOcassion); //Updating the array
    }

    address[] public goldAddress;
    uint256 public goldTokens = 100;



    function buyTicket(uint256 id) public payable {
        Ocassion storage thisOcassion = noOfOcassions[id];
        require(
            thisOcassion.maxNoOfTicekts >= thisOcassion.nthTicket,
            "All ticekts sold"
        );

        bool goldenuser;
        for (
            uint256 i = 0;
            i < goldAddress.length;
            i++ //This purchase is for goldAddress ppl
        ) {
            if (msg.sender == goldAddress[i]) {
                thisOcassion.nthTicket++;
                thisOcassion.attendants.push(msg.sender);
                for (uint256 j = i; j < goldAddress.length - 1; j++) {
                    goldAddress[j] = goldAddress[j + 1]; //Start shifting from the msg.value address
                }
                goldAddress.pop();

                // goldAddress[msg.value] = address(0);         //Removing the user from goldedTokens list
                goldTokens++;
                goldenuser = true;
               
            }
        }

        if (goldenuser == false) {
            require(msg.value == thisOcassion.price);
            thisOcassion.nthTicket++;
            thisOcassion.attendants.push(msg.sender); //Added the user to the event

        }

        address  payable  user = thisOcassion.ocassionManager;
        user.transfer(thisOcassion.price);                    

        arr[id] = thisOcassion; //Updating the array
    }



    function buyGoldenTokens() public payable {
        bool goldenAddress;
        for (uint256 i = 0; i < goldAddress.length; i++) {
            if (msg.sender == goldAddress[i]) {
                goldenAddress = true;
            }
        }

        require(goldenAddress == false, "You are already a Premium man");
        require(msg.value == 0.1 ether, "Please pay exact amount");
        require(goldTokens > 0, "All Tokens are sold! Try again in a few days");
        goldAddress.push(msg.sender);
        goldTokens--;
    }
function showTickets(uint id) view  public returns(uint) {
        uint   myTickets = 0;
        Ocassion storage thisOcassion = noOfOcassions[id];
        for (uint i =0; i<thisOcassion.attendants.length; i++) 
        {
            if (thisOcassion.attendants[i]==msg.sender) {
                myTickets++;
            }

        }
        return myTickets;
    }


    //Contract is ready but sirf jo occcassionManager hai usko paise bhejne hai uska likho function also isme ek loophole hai ki like when i am a golden user main woh agar event jyada costly hoga than our normal goldtoken price then hum kaha se paise denge na.as contract mein utne paise hi nhai hai na 
    //So abhi ke liye main har event ki cost less rakh raha hu than our token cost 



}