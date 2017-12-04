# README

Web Server that allows users to keep track of metadata about media files. Involved designing a relational database and a web server to allow users to insert their file metadata, in hierarchical structures, create categories for them, and query their media file. This was written with Ruby on Rails using a PostgreSQL database as a school project.




User Manual

Singing up and logging in are straightforward

Divided into four parts, 3 of which are links
	Category Manager: create categories, create relationships between them, view dagrs
	Add dagrs: manually add dagrs, insert files from pc
	Query dagrs: query the dangers and perform operations on them

				Adding dagrs

Manujle instert:	enter filename, storage path, and filesize, name and keywords can be left blank. If you are entering a html document to be parsed it must end in .html
Ex: http://website/folder/index.html would be
Filename:index.html           storeage path: http://website/folder

File Insert:	WARNING: first you must manually refresh the page for this to work
	Secondly you must click choose files to select the files you wish to include
	Then you must manually enter the storage path for the dagrs, lastly click add Files

Last method is a java program, more on this later

Dagr Tables
When dangers are displayed in tabular format, they can be altered
Select the dagrs you want to manipulate in the checkboxes.
There is a select all button that only works if you first manually refresh the page

Add to Category: select the category from the drop down menu and click add to category
Remove from category: click remove from category, will remove from whatever categories they 	   	   are in.
Delete Dagr: two options, select all dagrs to delete then click delete dagr!, this will just deleted them

Full delete: select one dagr and click full delete!, this will step through the dangers parents and children and ask if you want to delete them.

To add dagrs as children to other dangers, you must copy the guid of the parent dagr, select all the dangers you want to be children, and paste in the dagr guid into the text box, then click add children

	In addition each tabular format will allow to click the name to go to the dagr page
	And clicking the file_name will take you to the url behind the dagr
	Form the dagr page you can change the name and annotations of the dagr

			Category Manager

You can create new categories by entering the name then clicking add category
Below is a circle display of the categories
						Categories page

Clicking a category will take you to its category page which will show its parent, its children
And all its dangers in that category

Here here can delete the category by clicking delete category

Adding new category as child. You can enter the name and click add child to create a new categories and add it as a child to this category

You can also use the select box below to select an existing category and click add an existing category as child to do so

					Queries
The query page allows you to query dagrs, metadata,orphan/sterile/and time range
These are all very self explanatory except from the checkbox by metadata query
First enter the the keywords in format first,second,third   it is the last text field there
Select the checkbox to find only dagrs where all the keywords match
By default only some keywords need to match

	Reach queries can only be done from the dagr page of a individual dagr
To get there click the dagr name in a tabular display

Select the leave in text field, then up or down,then click reach query

					Bulk insert
The bulk insert is done with a java program that will recursively traverse the user’s file directory and add each dagr of the files. Each folder the files on in will be the category for that dagr

The compile and run commands are provided in the README

To run set the config.txt to line1: url for web server, line2: username, line3: password

Rub the program and provide 1 argument which is the full path to a file
Add 1 file:                                                    ------- mediaFile ~/Documents/music/blues.mp3
Recursively add all dagrs in file:                 -------- mediaFile ~/Documents/music/

Make sure there is a slash on the end

