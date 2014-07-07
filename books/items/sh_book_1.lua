ITEM.name = "Book 1"
ITEM.uniqueID = "book1"
ITEM.category = "Books"
ITEM.flag = "b"
ITEM.weight = 1
ITEM.price = 9001 // It's over 9000!
ITEM.model = Model("models/props_lab/binderblue.mdl")
ITEM.desc = "A simple book, but needlessly expensive. Written by Lauren Faust."
ITEM.data = {}

ITEM.functions = {}
ITEM.functions.Use = {
	text = "Read",
	run = function(itemTable, client, data)
		if (CLIENT) then return end
		
		client:UpdateInv("book1", 1, nil, true) // I'm too busy to develop a new function, so I use the 'Use' function of NS and I make it to give a book to user.
		nut.util.Notify("You started to read the book.", client)
		netstream.Start(client, "nut_book1")
	end
}