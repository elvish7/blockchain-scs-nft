const ABI = "./abi.json";
const ADDRESS = "0x06dddD462F3Ca3639f0c6a7c3b4017811CeEd7a9";
var account = null;
var contract = null;

(async () => {
    if (window.ethereum) {
        await window.ethereum.send('eth_requestAccounts');
        window.web3 = new Web3(window.ethereum);

        var accounts = await web3.eth.getAccounts();
        account = await accounts[0];
        contract = new web3.eth.Contract(await $.get(ABI), ADDRESS);
    }
})();

// Register
document.getElementById('register').onclick = () => {
    var cName = String(document.querySelector("[name=cName]").value);
    var date = String(document.querySelector("[name=date]").value).split('-').join('');
    var amount = Number(document.querySelector("[name=amount]").value);
    var keys = Array.from(document.querySelector("[name=keys]").value.split('/'));
    contract.methods.register(cName, date, amount, keys).send({ from: account, gas: 4700000}) //value: 50000000000000000
                                                        .catch((error) => {
                                                            alert(error['message'])}); 
}

// Launch vote
document.getElementById('vote').onclick = () => {
    var cName_vote = String(document.querySelector("[name=cName_vote]").value);
    var receiver = String(document.querySelector("[name=receiver]").value).split('-').join('');
    var amount_vote = Number(document.querySelector("[name=amount_vote]").value);
    contract.methods.launchVote(cName_vote, receiver, amount_vote).send({ from: account, gas: 4700000}) //value: 50000000000000000
                                                        .then(function( tokenID ){
                                                            console.log(tokenID[0]);
                                                        })
                                                        .catch((error) => {
                                                            alert(error['message'])}); 
}

// Sign
document.getElementById('sign_mint').onclick = () => {
    var token_sign = String(document.querySelector("[name=token_sign]").value);
    contract.methods.sign(token_sign).send({ from: account, gas: 4700000}) //value: 50000000000000000
                                    .catch((error) => {
                                        alert(error['message'])}); 
}
document.getElementById('sign_split').onclick = () => {
    var token_sign = String(document.querySelector("[name=token_sign]").value);
    contract.methods.signSplit(token_sign).send({ from: account, gas: 4700000}) //value: 50000000000000000
                                    .catch((error) => {
                                        alert(error['message'])}); 
}

// Search company's info
document.getElementById('search-button').onclick = () => {
    var search_cName = String(document.querySelector("[name=search]").value);
    contract.methods.lookup(search_cName).call()
                    .then(function( info ) { 
                        document.getElementById('results').style.display="block";
                        document.getElementById('noC').style.display = "none";
                        document.getElementById('getcName').textContent = info[0];
                        document.getElementById('getfDate').textContent = info[1];
                        document.getElementById('getoshare').textContent = info[2];
                        document.getElementById('getcertificates').textContent = info[3];
                    })
                    .catch((error) => {
                        document.getElementById('noC').style.display = "block";
                        document.getElementById('results').style.display="none";
                    });
}

// Burn
document.getElementById('burn').onclick = () => {
    var owner = String(document.querySelector("[name=owner]").value);
    var token_burn = String(document.querySelector("[name=token_burn]").value);
    try{
       contract.methods.redemption(owner, token_burn).send({ from: account, gas: 4700000}) //value: 50000000000000000
                                    .catch((error) => {
                                        alert(error['message'])});  
    }
    catch (error){
        document.getElementById('burn-err').style.display = "block";
    }
    
}
