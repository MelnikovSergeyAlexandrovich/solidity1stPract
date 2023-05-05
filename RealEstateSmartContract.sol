// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract EstateSmartContract {

address public owner;

constructor() {
owner = msg.sender; // msg - это глобальный объект, в котором хранится информация о совершенной транзакции; Sender - это свойство, которое вернет оправителя транзакции из объекта message
} //A Solidity constructor is called once when a new instance of a smart contract is deployed in Ethereum blockchain.

mapping(address => uint) public payments;

enum TypeOfState{
    apartment, bungalo, house //перечисление типов недвижимости 
}

enum Status{
    Sold, OnSale //вместо переменной bool
}

struct Estate {
address payable Owner;
uint Square;
string InfoAboutEstate;
uint Price;
TypeOfState Type;  
string PhotoLink;
Status StatusOfEstate;
string PhoneNumber;
uint index;
}

struct Buying{
    uint DateOfSale;
    uint Price;
    Estate estate;
}

Estate[] public Estates; //создание экземпляров enum-ов
Buying[] public Buys;

event listingCreated(address payable Owner, uint Square, string InfoAboutEstate, uint Price, TypeOfState Type, 
string PhotoLink, Status StatusOfEstate, string PhoneNumber); //создаём ивент - создание нового листинга, т.е. размещения объявления о продаже недвижимости
event listingEnded(uint index, address payable Owner, uint Square, string InfoAboutEstate, uint Price, TypeOfState Type,  //Event in solidity is to used to log the transactions happening in the blockchain.
string PhotoLink, Status StatusOfEstate, string PhoneNumber);

modifier onlyOwner() { //показывается тому, кто owner
//Modifiers are typically used in smart contracts to make sure that certain conditions are met before proceeding to executing the rest of the body of code in the method. - местный аналог try - throw (Exception e)
require(msg.sender == owner,"fYOU DO NOT OWN THIS HOUSE"); //seller - msg.owner - меняется при продаже на того, кто купил
_; //Объявление шаблона функции
}



function createListing(address payable _Owner, uint _Square, string memory _InfoAboutEstate, uint _Price, TypeOfState _Type, 
string memory _PhotoLink, Status _StatusOfEstate, string memory _PhoneNumber, uint _index) external {

Estate memory newEstate = Estate({
Owner: _Owner,
Square: _Square,
InfoAboutEstate: _InfoAboutEstate,
Price: _Price,
Type: _Type,
PhotoLink: _PhotoLink,
StatusOfEstate: _StatusOfEstate,
PhoneNumber: _PhoneNumber,
index: _index
}); 

Estates.push(newEstate); //добавляю в конец листа новый листинг)

emit listingCreated(_Owner, _Square, _InfoAboutEstate, _Price,_Type,_PhotoLink,_StatusOfEstate,_PhoneNumber);
} //Emit keyword is used to emit an event in solidity, which can be read by the client in Dapp.

function getPriceFor(uint index) public view returns(uint) {
Estate memory cEstate = Estates[index];
require(cEstate.StatusOfEstate == Status.Sold, "Sold out!"); //если досм продан, выводится ошибка
return cEstate.Price; // в другом случае возвращается цена
}
// Для покупки недвижимости пользователь должен указать номер покупаемой недвижимости и перевести нужную сумму. 
//При покупке у недвижимости меняется владелец и статус объявления меняется на "Продано". 
//У недвижимости должна быть своя структура. При покупке недвижимости должны быть следующие проверки:
// 1. Количество отправленной валюты должно быть больше или равно цене недвижимости.
// 2. У недвижимости должен быть статус "В продаже".
// 3. Покупатель не должен являться владельцем недвижимости. 
function buy(uint index) external payable {
Estate storage cEstate = Estates[index];
//require(!cAuction.stopped, "stopped!");
//require(block.timestamp < cEstate.endsAt, "ended!"); //block.timestamp - в бэке будем делать нормальное время
uint cPrice = getPriceFor(index); // получаем цену 
require(cEstate.Owner != msg.sender,"You already own this house!");
require(cEstate.StatusOfEstate == Status.Sold, "This house is sold out!");
require(msg.value >= cPrice, "not enough funds!"); //если денег на балике меньше, чем стоит данный дом
 //если дом не является проданным
 //если настоящий пользователь не является владельцем недвижимости
uint elapsed = block.timestamp; 
Buying memory cBuying = Buying({
    DateOfSale: elapsed,
    Price: cEstate.Price,
    estate: cEstate
});
cEstate.Owner = payable(msg.sender);
cEstate.StatusOfEstate = Status.Sold;
cEstate.Owner.transfer(cPrice); //перевод суммы за дом владельцу
Buys.push(cBuying);
emit listingEnded(index, payable(msg.sender), cEstate.Square, cEstate.InfoAboutEstate, cPrice, cEstate.Type, cEstate.PhotoLink, cEstate.StatusOfEstate, cEstate.PhoneNumber);
}
// 3) Продавец может списать деньги со счёта смарт контракта за проданную недвижимость. Проверки:
// 1) Списать деньги может только владелец проданной недвижимости
// 2) Если недвижимость не продана. то деньги списать нельзя.
// 3) Если покупатель хочет списать деньги, но их на смарт-контракте нет - выводить ошибку. Для этого необходимо ввести журнал проданных и купленных недвижимости.
function withdraw() external onlyOwner() { //вывод денежных средств
payable(msg.sender).transfer(address(this).balance); //this - именно баланс данного контракта 
}

}

/*
Infinite Gas
I suspect this is because the cost of those functions is indeed unbounded.
Strings can be of any length, so setNewMessage() needs to store an unbounded amount of data, and getMessage() needs to read an unbounded amount of data.
If you want to avoid that warning, you'd have to use a data type with a fixed upper bound on its size.
*/
