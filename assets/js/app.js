import "phoenix_html";
import "bootstrap";
import React from 'react';
import ReactDOM from 'react-dom';

import socket from "./socket";

import Game from "./game";

function ready(channel, state) {
  let root = document.getElementById('root');
  ReactDOM.render(<Game state={state} channel={channel} />, root);
}

function start(gameName) {
  if (!gameName) {
      gameName = prompt("Please specify a game name", "Game");
  }
  if(gameName !== null) {
      let channel = socket.channel("game:" + gameName, {});
      channel.join()
          .receive("ok", state0 => {
              console.log("Joined successfully", state0);
              ready(channel, state0);
          })
          .receive("error", resp => {
              console.log("Unable to join", resp);
          });
  }
}

function handleHashes() {
    location.hash.substring(1, 5)
    if (location.hash.slice(1) == "create") {
        start(null);
    } else if (location.hash.substring(1, 5) == "join") {
        start(location.hash.slice(6));
    } else if (location.hash.slice(1) == "reload") {
        location.assign(location.origin);
    }else {
        location.hash = "";
    }
}

$(window).on('hashchange', function() {
    handleHashes();
});

$(document).ready(function() {
    handleHashes();
});