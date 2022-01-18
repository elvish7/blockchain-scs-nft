const ABI = "./abi.json";
const ADDRESS = "0xaD075d18908D917164E165bf44ab67186F8Ff1bB";

var account = null;
var contract = null;

(async () => {
    if (window.ethereum) {
        await window.ethereum.send('eth_requestAccounts');
        window.web3 = new Web3(window.ethereum);

        var accounts = await web3.eth.getAccounts();
        account = await accounts[0];

        contract = new web3.eth.Contract(await $.get(ABI), ADDRESS);

        document.getElementById('register').onclick = () => {
            var cName = String(document.querySelector("[name=cName]").value);
            var date = String(document.querySelector("[name=date]").value).split('-').join('');
            var amount = Number(document.querySelector("[name=amount]").value);
            var keys = Array(document.querySelector("[name=keys]").value);
            // contract.methods.register(cName, date, amount, keys).send({ from: account, 
            //                                                         gas: 4700000, value: 50000000000000000});
            contract.methods.register(cName, date, amount, keys).send({ from: account, gas: 4700000});
        }
    }
})();