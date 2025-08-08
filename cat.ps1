Add-Type -AssemblyName System.Media

$samplesPerSec = 8000
$totalSamples = 65536  # 8 seconds, more than enough to cover the cycle

$buffer = New-Object byte[] $totalSamples

for ($t = 0; $t -lt $totalSamples; $t++) {
    $part1 = [math]::Floor($t / 2) -shr 10
    $part2 = (($t % 16) * $t) -shr 8
    $part3 = $part1 -bor $part2
    $part4 = (8 * $t) -shr 12
    $part5 = $part3 -band $part4
    $part6 = $part5 -band 18
    $part7 = - [math]::Floor($t / 16) + 64
    $val = ($t * $part6) -bor $part7

    $val = $val -band 0xFF  # clamp 0-255

    $buffer[$t] = [byte]$val
}

# WAV header
$header = New-Object byte[] 44
[Text.Encoding]::ASCII.GetBytes("RIFF").CopyTo($header, 0)
[BitConverter]::GetBytes(36 + $buffer.Length).CopyTo($header, 4)
[Text.Encoding]::ASCII.GetBytes("WAVE").CopyTo($header, 8)
[Text.Encoding]::ASCII.GetBytes("fmt ").CopyTo($header, 12)
[BitConverter]::GetBytes(16).CopyTo($header, 16)               # Subchunk1Size
[BitConverter]::GetBytes([int16]1).CopyTo($header, 20)        # AudioFormat (PCM)
[BitConverter]::GetBytes([int16]1).CopyTo($header, 22)        # NumChannels
[BitConverter]::GetBytes($samplesPerSec).CopyTo($header, 24)  # SampleRate
[BitConverter]::GetBytes($samplesPerSec).CopyTo($header, 28)  # ByteRate
[BitConverter]::GetBytes([int16]1).CopyTo($header, 32)        # BlockAlign
[BitConverter]::GetBytes([int16]8).CopyTo($header, 34)        # BitsPerSample
[Text.Encoding]::ASCII.GetBytes("data").CopyTo($header, 36)
[BitConverter]::GetBytes($buffer.Length).CopyTo($header, 40)

# Combine header + data
$wavData = New-Object byte[] ($header.Length + $buffer.Length)
$header.CopyTo($wavData, 0)
$buffer.CopyTo($wavData, $header.Length)

$tempFile = [IO.Path]::Combine([IO.Path]::GetTempPath(), "bytebeat.wav")
[IO.File]::WriteAllBytes($tempFile, $wavData)

$player = New-Object System.Media.SoundPlayer $tempFile

while ($true) {
    $player.PlaySync()
}
