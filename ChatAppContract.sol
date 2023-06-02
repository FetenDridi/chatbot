// SPDX-License-Identifier:GLSI2
pragma solidity ^0.8.0;

contract Payment {

    // Structure de données pour stocker les messages envoyés
    struct MessageG {
        bytes32 encryptedMessage; // Contenu du message
        address[] recipients; // Adresse du destinataire
        address sender; // Adresse de l'expéditeur
        bool deleted; // Flag pour indiquer si le message a été supprimé ou non
    }


// Fonction pour envoyer un message à un destinataire et effectuer un paiement

    event messageP(address indexed from, string message, address to, string timestamp);

    function sendMessage(address payable _to, string memory _message, string memory time) public payable {
        require(msg.value >= 1e18, "Le montant envoy\u00e9 doit \u00eatre de 1 ETH");
        _to.transfer(msg.value);
        emit messageP(msg.sender, _message, _to, time);
    }



    // Mapping pour stocker les messages envoyés par adresse de destinataire
    mapping (address => MessageG[]) public messages;
    
    // Fonction pour envoyer un message à un groupe de destinataires
    function sendGrpMessage(address[] memory _recipients, string memory _messageContent) public {
        // Chiffrer le message
        bytes32 encryptedMessage = keccak256(bytes(_messageContent));
        
        // Ajouter le message à la liste des messages pour chaque destinataire
        for (uint i = 0; i < _recipients.length; i++) {
            messages[_recipients[i]].push(MessageG(encryptedMessage, _recipients, msg.sender, false));
        }
    }
    
// Fonction pour récupérer les messages pour une adresse donnée
    function getMessagesForAddress(address _address) public view returns (MessageG[] memory) {
        // Récupérer tous les messages pour l'adresse spécifiée
        MessageG[] memory allMessages = messages[_address];
        // Filtrer les messages non supprimés
        uint nonDeletedMessageCount = 0;
        for (uint i = 0; i < allMessages.length; i++) {
            if (!allMessages[i].deleted) {
                nonDeletedMessageCount++;
            }
        }
        MessageG[] memory result = new MessageG[](nonDeletedMessageCount);
        uint index = 0;
        for (uint i = 0; i < allMessages.length; i++) {
            if (!allMessages[i].deleted) {
                result[index] = allMessages[i];
                index++;
            }
        }
        return result;
    }





    // Fonction pour supprimer un message envoyé par l'expéditeur
    function deleteMessage(address _recipient, uint index) public {
        // Récupérer le message à l'index spécifié pour l'adresse du destinataire
        MessageG storage message = messages[_recipient][index];
        // Vérifier que l'appelant est l'expéditeur du message
        require(message.sender == msg.sender, "Vous n'\u00eates pas autoris\u00e9 \u00e0 supprimer ce message");
        // Marquer le message comme supprimé
        message.deleted = true;
    }
     
 
}



