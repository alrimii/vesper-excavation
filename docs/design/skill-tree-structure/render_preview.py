"""Render only the local static SVG to PNG. No Studio, game, input or device emulation."""
from pathlib import Path
from playwright.sync_api import sync_playwright

root = Path(__file__).resolve().parent
with sync_playwright() as p:
    browser = p.chromium.launch(executable_path=r'C:\Program Files\Google\Chrome\Application\chrome.exe', headless=True, args=['--disable-gpu'])
    page = browser.new_page(viewport={'width':2000,'height':1360}, device_scale_factor=1)
    page.set_content('<html><body style="margin:0">' + (root/'skill-tree-structure.svg').read_text(encoding='utf-8') + '</body></html>')
    page.screenshot(path=str(root/'skill-tree-structure.png'), full_page=True, timeout=15000)
    browser.close()
print('Rendered static design PNG')
