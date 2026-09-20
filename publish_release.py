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
    version = sys.argv[1] if len(sys.argv) > 1 else "v7.4.4"
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

### 🌟 លក្ខណៈពិសេសចម្បង (What's New):
1. **មុខងារកែប្រែសមីការ (In-Place Equation Editing)**៖
   - ចុចលើប៊ូតុង «កែប្រែសមីការ» ក្នុង Word នឹងលោតបើក Mathtype-kh ភ្លាមៗ
   - ផ្ទុកកូដ LaTeX នៃសមីការចាស់មកបង្ហាញក្នុង Editor ដោយស្វ័យប្រវត្តិ
   - ពេលចុច «បញ្ចូលទៅ Word» (⌘I / Enter) វានឹងលុបសមីការចាស់ចោល និងជំនួសដោយសមីការថ្មីត្រង់ទីតាំងដដែល
2. **រូបសញ្ញា Ribbon ថ្មី**៖ ប្តូររូបសញ្ញាផ្លូវការ MathType Root ($\\\\sqrt{{}}$) លើ Word Ribbon
3. **ទំហំ Zoom**៖ កំណត់លំនាំដើម 100%
4. **ព័ត៌មានអ្នកបង្កើត**៖ បង្ហាញឈ្មោះអ្នកបង្កើត `K.Reaksmey` ក្នុងផ្ទាំង About
5. **កញ្ចប់ដំឡើង All-in-One PKG**៖ ដំឡើងទាំងកម្មវិធី Mathtype-kh និង Word Plugin ក្នុងពេលតែមួយ

---

### 📦 ឯកសារដំឡើង (Download Installers):
- **`Mathtype-kh-{tag_name}.pkg`** (All-in-One Installer): កញ្ចប់ដំឡើងរួម ដំឡើងទាំង Mathtype-kh.app និង Word Plugin (ណែនាំ / Recommended)
- **`Mathtype-kh-WordPlugin-{tag_name}.pkg`** (Word Plugin Standalone): សម្រាប់ដំឡើងតែ Add-in លើ Microsoft Word
- **`Remove_mathtype_kh.pkg`** (Uninstaller): សម្រាប់លុប និងសម្អាត Mathtype-kh ទាំងអស់ចេញពីម៉ាស៊ីន
"""

    if existing:
        print(f"ℹ️ Release {tag_name} already exists (ID: {existing['id']})")
        release = existing
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
        ('Mathtype-kh.pkg', f'Mathtype-kh-{tag_name}.pkg', f'Mathtype-kh {tag_name} (All-in-One Installer)'),
        ('word_plugin/Mathtype-kh.pkg', f'Mathtype-kh-WordPlugin-{tag_name}.pkg', f'Word Plugin Installer {tag_name} (Standalone)'),
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
