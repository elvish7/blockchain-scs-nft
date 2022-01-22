const ABI = "./abi.json";
const ADDRESS = "0x77983aAce2C5F5ab9e251D83BEc16923669aEE08";
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
    try{ contract.methods.register(cName, date, amount, keys).send({ from: account, gas: 4700000}) //value: 50000000000000000
                                                        .catch((error) => {
                                                            alert(error['message'])}); 
        document.getElementById('register-err').style.display = "none";
    }
    catch (error){ document.getElementById('register-err').style.display = "block"; }
    
}

// Launch vote
document.getElementById('vote').onclick = () => {
    var cName_vote = String(document.querySelector("[name=cName_vote]").value);
    var receiver = String(document.querySelector("[name=receiver]").value).split('-').join('');
    var amount_vote = Number(document.querySelector("[name=amount_vote]").value);
    try{ contract.methods.launchVote(cName_vote, receiver, amount_vote).send({ from: account, gas: 4700000}) //value: 50000000000000000
                                                        .then(
                                                            function(result){
                                                                var tokenID = result.events.getVoteDetail.returnValues['id'];
                                                                var founders = result.events.getVoteDetail.returnValues['founders'];
                                                                document.getElementById('result-hint').style.display = "block";
                                                                document.getElementById('vote-id').textContent = tokenID;
                                                            })
                                                        .catch((error) => {
                                                            alert(error['message'])});
        document.getElementById('vote-err').style.display = "none";
    }
    catch (error){ document.getElementById('vote-err').style.display = "block"; }
}

// Check company's voting details


// Sign
document.getElementById('sign_mint').onclick = () => {
    var token_sign = String(document.querySelector("[name=token_sign]").value);
    try{ contract.methods.sign(token_sign).send({ from: account, gas: 4700000}) //value: 50000000000000000
                                        .catch((error) => {
                                            console.log(error);
                                            alert(error['message'])}); 
        document.getElementById('sign-err').style.display = "none";
    }
    catch (error){ document.getElementById('sign-err').style.display = "block"; }
}
document.getElementById('sign_split').onclick = () => {
    var token_sign = String(document.querySelector("[name=token_sign]").value);
    try{ contract.methods.signSplit(token_sign).send({ from: account, gas: 4700000}) //value: 50000000000000000
                                        .catch((error) => {
                                            alert(error['message'])}); 
        document.getElementById('sign-err').style.display = "none";
    }
    catch (error){ document.getElementById('sign-err').style.display = "block"; }
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

// Transacting
document.getElementById('transfer').onclick = () => {
    var from_address = String(document.querySelector("[name=from_address]").value);
    var to_address = String(document.querySelector("[name=to_address]").value);
    var token_trans = Number(document.querySelector("[name=token_trans]").value);
    try{ contract.methods.transacting(from_address, to_address, token_trans).send({ from: account, gas: 4700000})
                                                                                .catch((error) => {
                                                                                    alert(error['message'])}); 
        document.getElementById('transf-err').style.display="none";
    }
    catch (error){ document.getElementById('transf-err').style.display = "block"; }                           
}

// Burn
document.getElementById('burn').onclick = () => {
    var owner = String(document.querySelector("[name=owner]").value);
    var token_burn = String(document.querySelector("[name=token_burn]").value);
    try{ contract.methods.redemption(owner, token_burn).send({ from: account, gas: 4700000}) //value: 50000000000000000
                                    .catch((error) => {
                                        alert(error['message'])}); 
        document.getElementById('burn-err').style.display = "none"; 
    }
    catch (error){ document.getElementById('burn-err').style.display = "block"; }
}

// Launch split vote
document.getElementById('split-vote').onclick = () => {
    var token_split = Number(document.querySelector("[name=token_split]").value);
    var split_address1 = String(document.querySelector("[name=split_address1]").value);
    var split_address2 = String(document.querySelector("[name=split_address2]").value);
    var amount_split = Number(document.querySelector("[name=amount_split]").value);
    try{ contract.methods.launchSplitVote(token_split, split_address1, split_address2, amount_split).send({ from: account, gas: 4700000}) //value: 50000000000000000
                                    .catch((error) => {
                                        alert(error['message'])});
        document.getElementById('split-err').style.display = "block";
    }
    catch (error){ document.getElementById('split-err').style.display = "block"; }
}