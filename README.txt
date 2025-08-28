Imgur downloader program made in PowerShell.
Made this to use it with another tool of mine called reddit-dlp.

Possible arguments:
url=(string: post URL)
out=(string: output file name, gets decoded as hex UTF8 if it starts with a ?)
delay=(integer: how long to wait in seconds & retry when a request fails)
deletedhashes=(comma separated string list: detect deleted posts based off of file hashes)
deleteifs=(comma separated string list: a list of 'delete ifs', which marks the downloaded file as deleted if it's over (+), under (-), or equal (=) to a certain size, and optionally has a certain extension, for example -10000/gifv marks the file as deleted if it's under 10000 bytes and is a GIFV)
cleardeletedfiledata=(boolean: whether to clear files marked as deleted)
cleardeletedfileextension=(boolean: whether to clear the file extension of files marked as deleted)
deleteifnofile=(boolean: whether to mark the file as deleted if nothing was able to be downloaded)
redditdlpsorting (whether to put the file in a 'videos' or 'images' folder based off of its extension, used by my reddit-dlp program)

Basic example usage:
imgur-dlp -out=name -url=https://imgur.com/Y3dR5i0

Advanced example usage:
imgur-dlp -out name -url=https://imgur.com/Y3dR5i0 -deletedhashes=e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855,35a0932c61e09a8c1cad9eec75b67a03602056463ed210310d2a09cf0b002ed5,350c25fc445411a27092e1dbc2ec2e53f9895f109b52b8bc5aa466f1775bbe7d,9b5936f4006146e4e1e9025b474c02863c0b5614132ad40db4b925a10e8bfbb9 -deleteifs=-10000/gifv -cleardeletedfiledata=true -cleardeletedfileextension=true -deleteifnofile=true
