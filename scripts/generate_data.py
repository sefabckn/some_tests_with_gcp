#!/usr/bin/env python3
import csv, uuid, random
from datetime import datetime, timedelta
from pathlib import Path

random.seed(42)
DATA_DIR   = Path("data")
DATA_DIR.mkdir(exist_ok=True)
START      = datetime(2024, 1, 1)
DAYS       = 90
COUNTRIES  = ["US","BR","IN","PH","RU","ID","MX"]
SOURCES    = ["organic","paid_social","referral","influencer"]
CATEGORIES = ["music","gaming","talk","dance"]
EVENTS     = ["app_open","stream_start","stream_end","gift_sent","follow","share"]

def rts(base, max_h=23):
    return base + timedelta(hours=random.random() * max_h)

def write_csv(path, headers, rows):
    with open(path, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(headers)
        w.writerows(rows)
    print(f"  Wrote {len(rows):,} rows → {path}")

# ── Users ──────────────────────────────────────────────
creator_ids = [str(uuid.uuid4()) for _ in range(300)]
viewer_ids  = [str(uuid.uuid4()) for _ in range(2000)]
users = []
user_signup = {}

for uid in creator_ids + viewer_ids:
    role   = "creator" if uid in creator_ids else "viewer"
    sd     = START + timedelta(days=random.randint(0, DAYS - 1))
    source = random.choice(SOURCES)
    users.append([uid, role, random.choice(COUNTRIES), sd.strftime("%Y-%m-%d"), source])
    user_signup[uid] = sd

write_csv(DATA_DIR / "users.csv",
          ["user_id","role","country","signup_date","acq_source"], users)

# ── Streams ────────────────────────────────────────────
streams   = []
stream_to_creator = {}
creator_stream_map = {cid: [] for cid in creator_ids}

for cid in creator_ids:
    sd       = user_signup[cid]
    # Simulate realistic dropoff: most churn fast
    n        = random.choices([0,1,2,5,10,20], weights=[15,20,25,20,15,5])[0]
    for i in range(n):
        # Later streams have higher dropout chance (decaying activity)
        offset  = random.randint(0, min(DAYS - 1, max(7, 7 + i * 3)))
        started = rts(sd + timedelta(days=offset))
        dur_min = random.randint(5, 120)
        ended   = started + timedelta(minutes=dur_min)
        sid     = str(uuid.uuid4())
        peak    = random.randint(0, 300)
        streams.append([sid, cid, started.isoformat(), ended.isoformat(),
                        random.choice(CATEGORIES), peak])
        stream_to_creator[sid] = cid
        creator_stream_map[cid].append((sid, started, ended))

write_csv(DATA_DIR / "streams.csv",
          ["stream_id","creator_id","started_at","ended_at","category","peak_viewers"],
          streams)

# ── Gifts ──────────────────────────────────────────────
gifts = []
for sid, cid, ts_start, ts_end in [(s[0], s[1], datetime.fromisoformat(s[2]),
                                     datetime.fromisoformat(s[3])) for s in streams]:
    for _ in range(random.randint(0, 10)):
        sender   = random.choice(viewer_ids)
        offset_s = random.randint(60, max(61, int((ts_end - ts_start).seconds)))
        gifts.append([str(uuid.uuid4()), sender, cid, sid,
                      (ts_start + timedelta(seconds=offset_s)).isoformat(),
                      random.choice([10, 50, 100, 500, 1000])])

write_csv(DATA_DIR / "gifts.csv",
          ["gift_id","sender_id","recipient_id","stream_id","sent_at","gift_value_coins"],
          gifts)

# ── Sessions (viewer watch sessions) ──────────────────
sessions = []
for sid, cid, ts_start, ts_end in [(s[0], s[1], datetime.fromisoformat(s[2]),
                                     datetime.fromisoformat(s[3])) for s in streams]:
    stream_dur = max(30, int((ts_end - ts_start).seconds))
    n_viewers  = random.randint(0, 40)
    for _ in range(n_viewers):
        vid       = random.choice(viewer_ids)
        join_off  = random.randint(0, stream_dur - 10)
        watch_sec = random.randint(10, stream_dur - join_off)
        s_start   = ts_start + timedelta(seconds=join_off)
        s_end     = s_start + timedelta(seconds=watch_sec)
        sessions.append([str(uuid.uuid4()), vid, sid,
                         s_start.isoformat(), s_end.isoformat(), watch_sec])

write_csv(DATA_DIR / "sessions.csv",
          ["session_id","user_id","stream_id","session_start","session_end","watch_seconds"],
          sessions)

# ── Events (raw log) ──────────────────────────────────
events = []
for uid in creator_ids + viewer_ids:
    sd = user_signup[uid]
    for day_offset in range(DAYS):
        if random.random() > 0.3:
            continue
        day_ts = sd + timedelta(days=day_offset)
        for _ in range(random.randint(1, 5)):
            events.append([str(uuid.uuid4()), uid, None,
                           random.choice(EVENTS),
                           rts(day_ts).isoformat()])

write_csv(DATA_DIR / "events.csv",
          ["event_id","user_id","stream_id","event_type","event_ts"], events)

print("\nAll files generated in ./data/")