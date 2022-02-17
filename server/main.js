const command = "/note";
var note = [];

onNet('chatMessage', (src, author, text) => {
    if(src && text.startsWith(command)){
        setImmediate(()=>{
            emitNet("client:note", src);
            emitNet("client:openNotepad", src);
            emit("server:LoadsNote");
        })
    }
});

RegisterServerEvent("server:LoadsNote")
onNet("server:LoadsNote", async () => {
    emitNet('client:updateNotes', -1, note.filter(n => n));
});

RegisterServerEvent("server:newNote")
onNet("server:newNote", async (d,x,y,z) => {
    note.push({ text: JSON.stringify(d), "x": x, "y": y, z: z });
    emit("server:LoadsNote");
});

RegisterServerEvent("server:updateNote")
onNet("server:updateNote", async (i, d) => {
    note[i].text = d;
    emit("server:LoadsNote");
});

RegisterServerEvent("server:destroyNote")
onNet("server:destroyNote", async (text,x,y,z) => {
    console.log("Deleting: " + JSON.stringify(note));
    for ( let i = 0; i < note.length; i++ ) {
        if ( note[i].text === text && note[i].x === x && note[i].y === y && note[i].z === z) {
            delete note[i];
        }
    }
    emit("server:LoadsNote");
});

RegisterServerEvent("server:consolelog")
onNet("server:consolelog", async (args) => {
    console.log(JSON.stringify(note.filter(n => n)));
    console.log(args);
});