Output "demo.gif"
Set TypingSpeed 75ms
Set FontSize 13
Set Width 1024
Set Height 768

# Show docker-compose.yml
Type "cat docker-compose.yml"
Enter
Sleep 5s

# Clear and pull
Type "clear"
Enter
Sleep 500ms
Type "docker compose pull"
Enter
Sleep 5s

# Spin up
Type "docker compose up -d"
Enter
Sleep 20s

# Verify services
Type "docker compose ps"
Enter
Sleep 8s

# Test Odoo
Type "curl -s http://localhost:8069 | head -30"
Enter
Sleep 8s
