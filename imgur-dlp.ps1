# imgur-dlp main script
# Made by Doggo (aka doge8000)





if (-not (Test-Path "deleted")) {
New-Item -Path "deleted" -ItemType Directory | Out-Null
}





function Get-CharacterCode {
param($char)
if ($char.Length -eq 1) {
$unicode = [System.String]::Copy($char)
$codePoint = [int][char]$unicode
return ($codePoint.ToString("X4"))
} elseif ($char.Length -eq 2) {
$c1 = [int]("0x" + ("{0:X2}" -f [int][char]($char[0])))
$c2 = [int]("0x" + ("{0:X2}" -f [int][char]($char[1])))
$c3 = ("{0:X}" -f ((($c1 - 0xD800) * 0x400) + ($c2 - 0xDC00) + 0x10000))
return "$c3"
} else {
return "0000"
}
}





function Get-EncodedString {
param($string)
$final = @()
for ($i = 0; $i -lt $string.Length; $i++) {
$char = $string[$i]
$codePoint = [int][char]$char
if (($codePoint -ge 0xD800 -and $codePoint -le 0xDBFF) -or ($codePoint -ge 0xDC00 -and $codePoint -le 0xDFFF)) {
$final += (Get-CharacterCode ($string[$i] + $string[$i + 1]))
$i++
} else {
$final += (Get-CharacterCode $string[$i])
}
}
return ($final -join "_")
}





function Get-DecodedString {
param($string)
$decoded = ""
$string_split = ($string -split "_")
foreach ($hex in $string_split) {
$decoded += ([char]::ConvertFromUtf32([int]("0x$hex")))
}
return $decoded
}





$global:url = $null
$global:out = $null
$global:delay = 30
$global:redditdlpsorting = $false
$global:deleted_hashes = ""
$global:delete_ifs = ""
$global:clear_deleted_file_data = $false
$global:clear_deleted_file_extension = $false
$global:delete_if_no_file = $false

foreach ($v in $args) {
if ($v.StartsWith("url=")) {
$global:url = ($v.Substring(4))
} elseif ($v.StartsWith("out=")) {
$global:out = ($v.Substring(4))
} elseif ($v.StartsWith("delay=")) {
$global:delay = [int]($v.Substring(6))
} elseif ($v.StartsWith("deletedhashes=")) {
$global:deleted_hashes = $v.Substring(14)
} elseif ($v.StartsWith("deleteifs=")) {
$global:delete_ifs = $v.Substring(10)
} elseif ($v.StartsWith("cleardeletedfiledata")) {
$global:clear_deleted_file_data = $true
} elseif ($v.StartsWith("cleardeletedfileextension")) {
$global:clear_deleted_file_extension = $true
} elseif ($v.StartsWith("deleteifnofile")) {
$global:delete_if_no_file = $true
} elseif ($v -eq "redditdlpsorting") {
$global:redditdlpsorting = $true
}
}

if ($global:url -eq $null) {
Write-Output "imgur-dlp: error: missing url argument"
exit
}

if ($global:out -eq $null) {
Write-Output "imgur-dlp: error: missing out argument"
exit
}

if ($global:out.StartsWith("?")) {
$decodeSuccess = $false
Write-Output "imgur-dlp: warning: out got starting '?', trying to decode rest of path as hex"
try {
$hexString = $global:out.Substring(1)
$global:out = (Get-DecodedString "$hexString")
$decodeSuccess = $true
} catch {
Write-Output "imgur-dlp: warning: failed to decode, keeping hex and removing starting '?'"
$global:out = $global:out.Substring(1)
}
if ($decodeSuccess) {
Write-Output ("imgur-dlp: warning: successfully decoded path from hex to '" + $global:out + "'")
}
}

if ($deleted_hashes -eq "") {
$global:deleted_hashes = @()
} else {
$global:deleted_hashes = ($deleted_hashes -split ";")
}

if ($delete_ifs -eq "") {
$global:delete_ifs = @()
} else {
$global:delete_ifs = ($delete_ifs -split ";")
}

Write-Output "imgur-dlp: deleted hashes:"
Write-Output "$deleted_hashes"

Write-Output "imgur-dlp: deleted IFs:"
Write-Output "$delete_ifs"

Write-Output "imgur-dlp: clear deleted file data:"
Write-Output "$clear_deleted_file_data"

Write-Output "imgur-dlp: clear deleted file extension:"
Write-Output "$clear_deleted_file_extension"

Write-Output "imgur-dlp: delete if no file:"
Write-Output "$delete_if_no_file"





$global:user_agents = @(
"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.10 Safari/605.1.1",
"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.3",
"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.3",
"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.3",
"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36 Trailer/93.3.8652.5",
"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36 Edg/134.0.0.",
"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36 Edg/131.0.0.",
"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36 OPR/117.0.0.",
"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36 Edg/132.0.0.",
"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36 Edge/18.1958",
"Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:136.0) Gecko/20100101 Firefox/136.",
"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.3",
"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36",
"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36 Edg/134.0.3124.85",
"Mozilla/5.0 (Windows NT 10.0; Win64; x64; Xbox; Xbox One) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36 Edge/44.18363.8131",
"Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:136.0) Gecko/20100101 Firefox/136.0",
"Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:128.0) Gecko/20100101 Firefox/128.0",
"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36 OPR/118.0.0.0",
"Mozilla/5.0 (Windows NT 10.0; WOW64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36 OPR/118.0.0.0",
"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36",
"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36 Edg/134.0.3124.85",
"Mozilla/5.0 (Macintosh; Intel Mac OS X 14.7; rv:136.0) Gecko/20100101 Firefox/136.0",
"Mozilla/5.0 (Macintosh; Intel Mac OS X 14.7; rv:128.0) Gecko/20100101 Firefox/128.0",
"Mozilla/5.0 (Macintosh; Intel Mac OS X 14_7_4) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.3 Safari/605.1.15",
"Mozilla/5.0 (Macintosh; Intel Mac OS X 14_7_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36 OPR/118.0.0.0",
"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36",
"Mozilla/5.0 (X11; Linux i686; rv:136.0) Gecko/20100101 Firefox/136.0",
"Mozilla/5.0 (X11; Linux x86_64; rv:136.0) Gecko/20100101 Firefox/136.0",
"Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:136.0) Gecko/20100101 Firefox/136.0",
"Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:136.0) Gecko/20100101 Firefox/136.0",
"Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:136.0) Gecko/20100101 Firefox/136.0",
"Mozilla/5.0 (X11; Linux i686; rv:128.0) Gecko/20100101 Firefox/128.0",
"Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:128.0) Gecko/20100101 Firefox/128.0",
"Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0",
"Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0",
"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36 OPR/118.0.0.0"
)

$global:headers = @{}





function Get-FileExtensionFromUrl {
param($url)
$url_1 = ($url -split "\?")[0]
$ext_1 = ((("$url_1") -split "/")[(("$url_1") -split "/").Length - 1])
$ext = ""
if ($ext_1.Contains(".")) {
$ext = ("." + (($ext_1 -split "\.")[($ext_1 -split "\.").Length - 1]))
if ($ext -eq ".") {
$ext = ""
}
}
return $ext
}





function Get-UrlWithoutExtension {
param($url)
return $url.Substring(0, ($url.Length - ((Get-FileExtensionFromUrl $url).Length)))
}





function Move-ToDeleted {
param($at)
Move-Item -LiteralPath "$at" -Destination ".\deleted\" -Force
$new_at = (".\deleted\" + ($at -split "\\")[($at -split "\\").Length - 1])
if ($clear_deleted_file_data -eq $true) {
Write-Output "Clearing file data"
Clear-Content -LiteralPath "$new_at"
}
if ($clear_deleted_file_extension -eq $true) {
Write-Output "Clearing file extension"
Rename-Item -LiteralPath "$new_at" -NewName ((($at -split "\\")[($at -split "\\").Length - 1]) + ".deleted")
}
}





function Check-IfFileDelete {
param($at)
if (Test-Path -LiteralPath "$at") {
$file_info = (Get-Item -LiteralPath "$at")
$file_size = $file_info.Length
$file_ext = $file_info.Extension

foreach ($delete_if in $global:delete_ifs) {
$delete_if_1 = ($delete_if -split "/")[0]
$delete_if_2 = ($delete_if -split "/")[1]
$matches_1 = $false
$matches_2 = $false
if ($delete_if_1 -eq $null) {
$matches_1 = $true
}
if ($delete_if_2 -eq $null) {
$matches_2 = $true
}
if ($matches_1 -eq $false) {
$parsed_int = [int]($delete_if_1.Substring(1))
if ($delete_if_1.StartsWith("+")) {
if ($file_size -ge $parsed_int) {
$matches_1 = $true
}
} elseif ($delete_if_1.StartsWith("-")) {
if ($file_size -le $parsed_int) {
$matches_1 = $true
}
} elseif ($delete_if_1.StartsWith("=")) {
if ($file_size -eq $parsed_int) {
$matches_1 = $true
}
}
}
if ($matches_2 -eq $false) {
if ((".$delete_if_2").ToUpper() -eq $file_ext.ToUpper()) {
$matches_2 = $true
}
}
if (($matches_1 -eq $true) -and ($matches_2 -eq $true)) {
$matches_delete_if = $true
Write-Output "Check-IfFileDelete: File '$at' matches delete IF '$delete_if' - moving to \deleted"
Move-ToDeleted "$at"
return
}
}

foreach ($hash in $deleted_hashes) {
$true_hash = ""
# check size before using hash
if ($hash.Contains("/")) {
$hash_split = ($hash -split "/")
$hash_size = $hash_split[0]
$true_hash = $hash_split[1]
if ($file_size.ToString() -ne "$hash_size") {
continue
}
} else {
$true_hash = $hash
}
# size is the same, check with hash
$file_hash = (Get-FileHash -Algorithm SHA256 -LiteralPath "$at").Hash
if ($file_hash -eq $true_hash) {
Write-Output "File hash matches deleted hash '$hash' - moving to \deleted"
Move-ToDeleted "$at"
return
}
}

} else {
Write-Output "Check-IfFileDelete: File not found at '$at'"

if ($delete_if_no_file -eq $true) {
Write-Output "Check-IfFileDelete: Creating .DELETED file"
$at2 = $at.Substring((($at -split "\\")[0]).Length + 1)
New-Item -Path "deleted\$at2.deleted" -ItemType File | Out-Null
}

}
}





$ProgressPreference = "SilentlyContinue"

$seen = @{}
$extracted = @()

if (
$url.StartsWith("https://www.i.imgur.com") -or
$url.StartsWith("https://i.imgur.com") -or
$url.StartsWith("http://www.i.imgur.com") -or
$url.StartsWith("http://i.imgur.com") -or
$url.StartsWith("www.i.imgur.com") -or
$url.StartsWith("i.imgur.com")
) {
$extracted = @($url)
} else {
while ($true) {
$suc = $true
try {
Write-Output "imgur-dlp: GET $url"
($global:headers)["User-Agent"] = (($global:user_agents)[(Get-Random -Minimum 0 -Maximum ($global:user_agents.Length))])
$res = (Invoke-WebRequest -Uri "$url" -Headers $headers -UseBasicParsing)
$split_res = ($res.Content -split "https:\/\/i\.imgur\.com\/")
$first = $true
foreach ($v in $split_res) {
if ($first -eq $false) {
$current = (($v -split "\\")[0] -split '"')[0]
if (-not $current.Contains("?")) {
if ($seen[$current] -eq $null) {
if ((Get-UrlWithoutExtension $current).Length -eq 7) {
$extracted += "https://i.imgur.com/$current"
$seen[$current] = $true
}
}
}
}
$first = $false
}
} catch {
$suc = $false
Write-Output "imgur-dlp: failed to extract URLs, will retry in $delay seconds - $_"
Start-Sleep $delay
}
if ($suc -eq $true) {
break
}
}
}





Write-Output "imgur-dlp: extracted URLs:"

if ($extracted.Length -eq 0) {
Write-Output "none"
if ($delete_if_no_file -eq $true) {
Write-Output "imgur-dlp: Creating .DELETED file"
New-Item -Path "deleted\$out.deleted" -ItemType File | Out-Null
}
} else {
Write-Output $extracted
}





$i = 1

foreach ($extracted_url in $extracted) {
while ($true) {
$suc = $true
try {
($global:headers)["User-Agent"] = (($global:user_agents)[(Get-Random -Minimum 0 -Maximum ($global:user_agents.Length))])
$out_extra = ""
if ($global:redditdlpsorting -eq $true) {
$ext = (Get-FileExtensionFromUrl "$extracted_url").ToUpper()
if ($ext -eq ".JPG") {
$out_extra = "images\"
} elseif ($ext -eq ".JPEG") {
$out_extra = "images\"
} elseif ($ext -eq ".PNG") {
$out_extra = "images\"
} elseif ($ext -eq ".APNG") {
$out_extra = "images\"
} elseif ($ext -eq ".WEBP") {
$out_extra = "images\"
} elseif ($ext -eq ".GIF") {
$out_extra = "images\"
} elseif ($ext -eq ".MP4") {
$out_extra = "videos\"
} elseif ($ext -eq ".MP3") {
$out_extra = "videos\"
} elseif ($ext -eq ".OGG") {
$out_extra = "videos\"
} elseif ($ext -eq ".WAV") {
$out_extra = "videos\"
} elseif ($ext -eq ".MKV") {
$out_extra = "videos\"
} elseif ($ext -eq ".AVI") {
$out_extra = "videos\"
} elseif ($ext -eq ".WEBM") {
$out_extra = "videos\"
} else {
$out_extra = "images\"
}
}
if ($extracted.Length -eq 1) {
Write-Output "imgur-dlp: GET $extracted_url > $out_extra$out"
Invoke-WebRequest -Uri "$extracted_url" -Headers $global:headers -OutFile (("$out_extra$out") + (Get-FileExtensionFromUrl "$extracted_url")) -UseBasicParsing
Check-IfFileDelete (("$out_extra$out") + (Get-FileExtensionFromUrl "$extracted_url"))
} else {
Write-Output "imgur-dlp: GET $extracted_url > $out_extra$out ($i)"
Invoke-WebRequest -Uri "$extracted_url" -Headers $global:headers -OutFile (("$out_extra$out ($i)") + (Get-FileExtensionFromUrl "$extracted_url")) -UseBasicParsing
Check-IfFileDelete (("$out_extra$out ($i)") + (Get-FileExtensionFromUrl "$extracted_url"))
}
$i += 1
} catch {
$suc = $false
Write-Output "imgur-dlp: request failled, will retry in $delay seconds - $_"
Start-Sleep $delay
}
if ($suc -eq $true) {
break
}
}
}
