"""Original editable workshop illustrations; raster export with already-installed Chromium.
Static artwork rendering only. No game/device/browser interaction testing.
"""
from pathlib import Path
from playwright.sync_api import sync_playwright
ROOT=Path(__file__).resolve().parent
ROOT.mkdir(exist_ok=True)
defs='''<defs>
<linearGradient id="wood" x2=".8" y2="1"><stop stop-color="#e6b76f"/><stop offset="1" stop-color="#9b5939"/></linearGradient>
<linearGradient id="steel" x2=".6" y2="1"><stop stop-color="#f9efd1"/><stop offset=".45" stop-color="#b6c7bd"/><stop offset="1" stop-color="#557b78"/></linearGradient>
<linearGradient id="gold" x2=".4" y2="1"><stop stop-color="#fff3b1"/><stop offset=".5" stop-color="#efbd52"/><stop offset="1" stop-color="#c47732"/></linearGradient>
<linearGradient id="stone" x2=".7" y2="1"><stop stop-color="#f0d7ac"/><stop offset="1" stop-color="#b58c62"/></linearGradient>
<linearGradient id="gem" x2=".8" y2="1"><stop stop-color="#c1ead5"/><stop offset=".5" stop-color="#4f9e8d"/><stop offset="1" stop-color="#23594f"/></linearGradient>
</defs>'''
pick='''<g transform="rotate(-32 128 128)"><path d="M116 73 L139 73 L142 216 Q128 231 113 217Z" fill="url(#wood)"/><path d="M116 167L140 161M116 182L141 176M116 197L141 191" stroke="#6f4431" stroke-width="9"/><path d="M38 80Q74 34 128 42Q190 36 222 82L178 66L146 69L144 92L110 92L108 69L77 66Z" fill="url(#steel)"/><path d="M63 67L106 54L155 54L192 66" fill="none" stroke="#fff5cf" stroke-width="7"/><path d="M109 67H145V89H109Z" fill="url(#gold)"/></g>'''
shell='''<path d="M29 188L56 148L107 145L141 173L131 222L49 229Z" fill="url(#stone)"/><path d="M60 149L74 178L61 194L86 222M74 178L109 174L124 195" fill="none" stroke="#805c45" stroke-width="6"/>'''
gem='''<path d="M89 42L131 22L169 54L176 157L127 210L79 159Z" fill="url(#gem)"/><path d="M89 42L120 64L131 22M120 64L169 54M120 64L127 210M120 64L79 159" fill="none" stroke="#d9efd3" stroke-width="5"/>'''
coin='''<ellipse cx="128" cy="140" rx="82" ry="80" fill="#a76a32"/><circle cx="128" cy="120" r="80" fill="url(#gold)"/><circle cx="128" cy="120" r="59" fill="none" stroke="#bf8339" stroke-width="8"/><path d="M149 88Q102 66 94 119Q100 169 151 149" fill="none" stroke="#80502c" stroke-width="17" stroke-linecap="round"/><path d="M81 60Q110 40 147 49" fill="none" stroke="#fff8c9" stroke-width="8"/>'''
art={
'Power': shell+'<g transform="translate(25 -23) scale(.87)"><g transform="rotate(180 128 128)">'+pick+'</g></g><path d="M157 145L182 119M170 169L210 158M142 125L145 97" stroke="#efbd52" stroke-width="9"/>',
'Speed':'<path d="M37 56H91M25 91H72M27 130H65" stroke="#d29b4d" stroke-width="13"/>'+ '<g transform="translate(26 1) scale(.86)">'+pick+'</g>',
'Capacity':'''<path d="M54 88Q58 18 128 18Q199 18 202 88" fill="none" stroke="#5c6861" stroke-width="17"/><path d="M40 84H216L201 213Q128 244 55 213Z" fill="url(#wood)"/><path d="M57 93L69 215M93 96L99 223M130 96V228M165 94L158 223M199 91L188 215" stroke="#805335" stroke-width="5"/><path d="M42 96Q128 126 215 96L212 116Q128 143 45 116Z M52 188Q128 215 204 188L201 210Q128 238 55 210Z" fill="url(#steel)"/><ellipse cx="128" cy="86" rx="88" ry="28" fill="#6b503a"/><path d="M72 85L92 40L120 68L131 27L164 55L181 88" fill="url(#gem)"/>''',
'Precision':shell+'''<path d="M114 34L143 22L174 48L136 156L112 177L107 145Z" fill="url(#steel)"/><path d="M135 152L115 173L109 150Z" fill="url(#gold)"/><path d="M99 163H74M120 187V214M143 163H169M119 139V115" stroke="#cf903d" stroke-width="7"/><path d="M54 49L61 35L69 49L83 56L69 63L61 77L54 63L40 56Z" fill="url(#gold)"/>''',
'Yield':'''<path d="M28 167L76 145L126 163L179 143L226 170L211 223H43Z" fill="url(#wood)"/><path d="M29 174L128 198L226 175M128 198V233" fill="none" stroke="#f3cd8b" stroke-width="8"/>'''+ '<g transform="translate(-26 49) scale(.6)">'+gem+'</g><g transform="translate(86 55) scale(.55)">'+gem+'</g><path d="M112 29H143V76H161L128 115L96 76H112Z" fill="url(#gold)"/>',
'Value':'<g transform="translate(-18 -8) scale(.73)">'+gem+'</g><g transform="translate(83 86) scale(.62)">'+coin+'</g><path d="M165 31L176 12L187 31L208 42L187 53L176 72L165 53L144 42Z" fill="url(#gold)"/>',
'Critical':'''<path d="M126 17L147 71L201 36L180 91L239 106L187 133L222 185L164 173L153 235L120 189L72 225L78 169L18 156L66 121L28 78L89 82Z" fill="url(#gold)"/><path d="M123 63L155 97L180 115L156 136L131 179L104 145L78 123L105 101Z" fill="url(#steel)"/><path d="M127 82L118 113L137 121L125 158" fill="none" stroke="#6f4c36" stroke-width="8"/>''',
'Credits':coin,
'Emblem':pick,
}
for name,body in art.items():
 svg=f'<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 256 256">{defs}<g stroke="#4b392d" stroke-width="5" stroke-linejoin="round" stroke-linecap="round">{body}</g></svg>'
 (ROOT/(name+'.svg')).write_text(svg,encoding='utf-8')
with sync_playwright() as pw:
 browser=pw.chromium.launch(executable_path=r'C:\Program Files\Google\Chrome\Application\chrome.exe',headless=True,args=['--disable-gpu'])
 page=browser.new_page(viewport={'width':256,'height':256},device_scale_factor=1)
 for name in art:
  svg=(ROOT/(name+'.svg')).read_text().replace('width="512" height="512"','width="256" height="256"')
  page.set_content('<html><body style="margin:0;background:transparent">'+svg+'</body></html>')
  page.screenshot(path=str(ROOT/(name+'.png')),omit_background=True)
 browser.close()
print('Exported nine original 256px RGBA illustrations from editable SVG sources.')
