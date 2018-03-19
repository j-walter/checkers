import {Socket} from "phoenix";

let socket = new Socket("/socket", {params: {token: document.head.querySelector("[name=user_token]").content}});
socket.connect();

export default socket;