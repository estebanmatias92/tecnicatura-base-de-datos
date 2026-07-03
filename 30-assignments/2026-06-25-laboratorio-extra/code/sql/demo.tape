Output "demo.gif"
Set TypingSpeed 75ms
Set FontSize 13
Set Width 1024
Set Height 768

# Show compose.yaml
Type "cat compose.yaml"
Enter
Sleep 5s

# Clear and spin up
Type "clear"
Enter
Sleep 500ms
Type "docker compose pull"
Enter
Sleep 5s
Type "docker compose up -d"
Enter
Sleep 8s

# Verify services
Type "docker compose ps"
Enter
Sleep 8s

# Curl adminer login page
Type "curl -s http://localhost:8080 | head -30"
Sleep 1s
Enter
Sleep 6s
