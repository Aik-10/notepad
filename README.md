Fivem Notepad script
===================================

Created By Lentokone

## Pictures
https://i.imgur.com/hie3acy.png
https://i.imgur.com/XhMQFIj.jpg

Install
==================
### resource

add to server.cfg
```
start lkrp_notepad
```
**Add "notepad" to items table**
SQL Query
```
INSERT INTO `items` (`name`, `label`, `limit`, `rare`, `can_remove`, `can_steal`) VALUES ('notepad', 'Notepad', 1, 0, 1, 1)
```
OR New ESX
```
INSERT INTO `fivem`.`items` (`name`, `label`) VALUES ('notepad', 'Notepad');
```
