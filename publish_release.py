#!/usr/bin/env python3
"""
Automated GitHub Release Publisher for Mathtype-kh.
Builds and uploads installer PKG files to GitHub Releases under the specified version tag.
"""
import sys
import os
import json
import subprocess
import urllib.request
import urllib.parse
import urllib.error

def get_git_credentials():
    proc = subprocess.run(['git', 'credential', 'fill'], input=b'protocol=https\nhost=github.com\n', capture_output=True)
    lines = proc.stdout.decode().splitlines()
    creds = dict(l.split('=', 1) for l in lines if '=' in l)
    return creds.get('password')

def main():
    version = sys.argv[1] if len(sys.argv) > 1 else "v7.4.5"
    if not version.startswith("v"):
        tag_name = "v" + version
    else:
        tag_name = version
        version = version[1:]

    token = get_git_credentials()
    if not token:
        print("❌ Error: Could not find GitHub token in git credentials.")
        sys.exit(1)

    headers = {
        'Authorization': f'Bearer {token}',
        'Accept': 'application/vnd.github+json',
        'User-Agent': 'Mathtype-kh-Publisher'
    }

    repo = "Krotreaksmey2200/Mathtype_kh"
    print(f"🚀 Publishing Release {tag_name} to {repo}...")

    # Check if release exists
    req = urllib.request.Request(f'https://api.github.com/repos/{repo}/releases', headers=headers)
    with urllib.request.urlopen(req) as resp:
        releases = json.loads(resp.read().decode())

    existing = next((r for r in releases if r.get('tag_name') == tag_name), None)

    body_text = f"""# Mathtype-kh {tag_name} (Native 64-bit Edition)

កំណែថ្មី {tag_name} ជាមួយការកែលម្អលើ UX/UI និងការតភ្ជាប់ជាមួយ Microsoft Word យ៉ាងរលូន។

### 🌟 លក្ខណៈពិសេសចម្បង (What's New in {tag_name}):
1. **🎨 មុខងារកំណត់ប្ដូរពណ៌សមីការ (Equation Color Customization)**៖
   - ម៉ឺនុយ **«ពណ៌ (Color)»** លើ Menu Bar ជាមួយ Shortcuts (`⌘0` ដល់ `⌘6` និង `⌘K`)
   - ប៊ូតុង **«Color / ពណ៌»** លើ Action Bar ជាមួយ Color Indicator Dot និង Palette ពណ៌ស្រស់ស្អាតទាំង ៨
   - គាំទ្រ **Custom Color Picker** សម្រាប់ជ្រើសរើសកូដពណ៌តាមចិត្ត
   - គាំទ្រទាំងការប្ដូរពណ៌សមីការទាំងមូល និងប្ដូរពណ៌តែផ្នែកដែលបាន Highlight (Selection-level styling)
   - រក្សាគុណភាពពណ៌កម្រិតខ្ពស់ **300 DPI** ពេលបញ្ចូលទៅកាន់ Microsoft Word, Vector SVG និង Vector PDF
2. **🚀 ប្រព័ន្ធធ្វើបច្ចុប្បន្នភាពស្វ័យប្រវត្តិក្នងកម្មវិធី (In-App Seamless Auto-Update)**៖
   - ធ្វើបច្ចុប្បន្នភាពបានភ្លាមៗ 1-Click Update ផ្ទាល់ក្នុងកម្មវិធី ដោយមិនចាំបាច់បើក Browser ឬដំឡើងសារជាថ្មីដោយដៃ
   - ផ្ទាំងស្ថានភាព Update ទំនើបជាមួយ Progress Bar ច្បាស់លាស់ ស្អាត និងគ្មានពាក្យ "GitHub"
3. **🇰🇭 មុខងារសរសេរអក្សរខ្មែរក្នុងសមីការ (Khmer Text in Math Mode)**៖ ប៊ូតុង «🇰🇭 អក្សរខ្មែរ» ឬចុច `⌘ + ⇧ + T` ដើម្បីសរសេរអក្សរខ្មែរក្នុងរូបមន្ត
4. **🌐 Pure English Localization**៖ មុខងារប្ដូរភាសាទៅអង់គ្លេសសុទ្ធ 100% លើ Menu Help, Edit, Size, Style, Modals, Tooltips និង Palettes
5. **🎯 ប៊ូតុងទាំង ៥ លើ MS Word (Word Ribbon Suite Integration)**៖
   - បើក Mathtype-kh ភ្លាមៗពី MS Word
   - កែប្រែសមីការ (Edit Selected Equation) ស្រង់សមីការដែលបានជ្រើសក្នុង Word ទៅកែក្នុង Mathtype-kh ដោយផ្ទាល់
   - Toggle TeX ($...$) បំប្លែងរវាងអក្សរ TeX និងរូបភាពសមីការ (Smart Paragraph Detection)
   - Align Selection & Align Document តម្រឹមបន្ទាត់កណ្តាលសមីការ (Mathematical Baseline) ដោយស្វ័យប្រវត្តិកម្រិតខ្ពស់សម្រាប់ `cases`, `matrix`, `aligned`, `int`, និង `frac`
6. **🧪 ផ្ទាំង និងរូបមន្តគីមីវិទ្យា (Chemistry Tab & mhchem)**៖ រូបមន្តប្រតិកម្មគីមី លំនឹងគីមីទ្វេទិស បន្ទុកអ៊ីយ៉ុង
7. **🕒 ប្រវត្តិសមីការ (History) និង ⭐ សំណព្វ (Favorites)**៖ រក្សាទុក ៣០ សមីការចុងក្រោយ ដាក់ផ្កាយ និងចុចប្រើឡើងវិញភ្លាមៗ (`⌘ + ⇧ + H`)
8. **✏️ ចុចពីរដងលើសមីការក្នុង Word ដើម្បីកែប្រែ (Double-Click in Word)**៖ Double-click លើរូបភាពសមីការក្នុង Word បើក Mathtype-kh កែប្រែភ្លាមៗ
9. **📄 នាំចេញជា Vector SVG និង Vector PDF**៖ ឯកសារ Vector គុណភាពខ្ពស់បំផុតកម្រិតបោះពុម្ព

---

### 📦 ឯកសារដំឡើង (Download Installers):
- **`Mathtype-kh-{tag_name}.pkg`** (All-in-One Installer): កញ្ចប់ដំឡើងរួម ដំឡើងទាំង Mathtype-kh.app និង Word Plugin (ណែនាំ / Recommended)
- **`Mathtype-kh.pkg`** (Latest All-in-One): តំណទាញយកកញ្ចប់ដំឡើងចុងក្រោយបំផុត
- **`Mathtype-kh-WordPlugin-{tag_name}.pkg`** (Word Plugin Standalone): សម្រាប់ដំឡើងតែ Add-in លើ Microsoft Word
- **`Remove_mathtype_kh-{tag_name}.pkg`** (Uninstaller): សម្រាប់លុប និងសម្អាត Mathtype-kh ទាំងអស់ចេញពីម៉ាស៊ីន
"""

    if existing:
        print(f"ℹ️ Release {tag_name} already exists (ID: {existing['id']})")
        release = existing
        # Update release description
        patch_payload = {'body': body_text}
        patch_req = urllib.request.Request(
            f'https://api.github.com/repos/{repo}/releases/{existing["id"]}',
            data=json.dumps(patch_payload).encode('utf-8'),
            headers={**headers, 'Content-Type': 'application/json'},
            method='PATCH'
        )
        urllib.request.urlopen(patch_req)
    else:
        print(f"📦 Creating release {tag_name}...")
        payload = {
            'tag_name': tag_name,
            'target_commitish': 'main',
            'name': f'Mathtype-kh {tag_name}',
            'body': body_text,
            'draft': False,
            'prerelease': False
        }
        req = urllib.request.Request(
            f'https://api.github.com/repos/{repo}/releases',
            data=json.dumps(payload).encode('utf-8'),
            headers={**headers, 'Content-Type': 'application/json'}
        )
        with urllib.request.urlopen(req) as resp:
            release = json.loads(resp.read().decode())
        print(f"✅ Created release successfully! ID: {release['id']}")

    upload_url_tmpl = release['upload_url']
    upload_base = upload_url_tmpl.split('{')[0]

    assets = [
        (f'Mathtype-kh-{tag_name}.pkg', f'Mathtype-kh-{tag_name}.pkg', f'Mathtype-kh {tag_name} (All-in-One Installer)'),
        ('Mathtype-kh.pkg', 'Mathtype-kh.pkg', 'Mathtype-kh (All-in-One Installer Latest)'),
        (f'Mathtype-kh-WordPlugin-{tag_name}.pkg', f'Mathtype-kh-WordPlugin-{tag_name}.pkg', f'Word Plugin Installer {tag_name} (Standalone)'),
        (f'Remove_mathtype_kh-{tag_name}.pkg', f'Remove_mathtype_kh-{tag_name}.pkg', f'Uninstaller {tag_name}: Completely Remove & Clean Mathtype-kh'),
        ('Remove_mathtype_kh.pkg', 'Remove_mathtype_kh.pkg', 'Uninstaller: Completely Remove & Clean Mathtype-kh')
    ]

    existing_assets = {a['name']: a['id'] for a in release.get('assets', [])}

    for local_path, remote_name, label in assets:
        if not os.path.exists(local_path):
            print(f"⚠️ Warning: File {local_path} not found. Skipping.")
            continue

        if remote_name in existing_assets:
            print(f"🔄 Asset {remote_name} already exists. Replacing...")
            del_req = urllib.request.Request(
                f'https://api.github.com/repos/{repo}/releases/assets/{existing_assets[remote_name]}',
                headers=headers,
                method='DELETE'
            )
            urllib.request.urlopen(del_req)

        print(f"⬆️ Uploading {remote_name} ({os.path.getsize(local_path)} bytes)...")
        with open(local_path, 'rb') as f:
            file_data = f.read()

        upload_url = f"{upload_base}?name={remote_name}&label={urllib.parse.quote(label)}"
        up_req = urllib.request.Request(
            upload_url,
            data=file_data,
            headers={
                'Authorization': f'Bearer {token}',
                'Content-Type': 'application/octet-stream',
                'User-Agent': 'Mathtype-kh-Publisher'
            }
        )
        with urllib.request.urlopen(up_req) as resp:
            asset_info = json.loads(resp.read().decode())
            print(f"✅ Uploaded: {asset_info.get('browser_download_url')}")

    print("🎉 All release assets published successfully!")

if __name__ == '__main__':
    main()
