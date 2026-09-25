# V4 — Future Exploration

**When: unscheduled. Nothing here is committed, gated, or built.**

## Why this document exists

Per this roadmap's honesty principle (`README.md`): don't claim something is built when it isn't. This document holds two kinds of not-yet-real idea, kept separate from the committed V1/V2/V3 versions rather than silently dropped or silently built without flagging the gap:

- **Claims that turned out not to be true.** While porting [AgriLite-FL](https://github.com/marknature/AgriLite-FL) into V2's Module 9 (crop/fertilizer recommendation, server-side disease diagnosis — see `V2_INTELLIGENCE_LAYER.md`), its README and repo name claimed two additional capabilities — federated learning and a multilingual chatbot — that **do not exist in its actual code**. `requirements.txt` has no Flower/PySyft/TensorFlow-Federated, and `app.py` has no chatbot route.
- **Real, out-of-scope ideas with genuine feasibility evidence**, moved here from V3's blue-sky "explicitly excluded" list to give them room for the "why it's credible / what's missing / what would gate it" treatment that list doesn't have space for — the Agri-Rover below.

## Idea: Federated learning for the crop/disease models

Train Module 9's models (or Part 2's on-device disease model) across many farmers'/extension offices' devices without centralizing raw farm data, using a real framework (Flower, TensorFlow Federated, or similar).

- **Nothing exists to port.** This would be a from-scratch distributed-systems build: a federated aggregation server, a client-side training loop on-device, secure aggregation, and a rollout/versioning story for updated models reaching offline-first phones.
- **Tension with the current architecture:** V1/V2 lean on-device and offline-first by design (Part 2's disease checker deliberately runs with no internet). Federated learning's value proposition — collaborative training without centralizing data — matters most once there's a large, active farmer base generating enough local data to make federation worthwhile. Before that, it's infrastructure built on a guess, the same pattern this roadmap avoids elsewhere (e.g. the V3 cold room).
- **Gate before starting:** real usage data from V1/V2 showing enough active devices/farms to make federated training meaningfully better than periodic centralized retraining (which Module 9 already does via `backend/scripts/train_crop_model.py`).

## Idea: Multilingual (English/Shona) chatbot

Conversational assistance for farmers, in English and Shona, per AgriLite-FL's stated (not built) ambition.

- **Nothing exists to port.** No chatbot code, prompt, or route exists anywhere in AgriLite-FL's repo.
- **What it would take:** an LLM or NLP pipeline with real Shona support (verified, not assumed — many multilingual models handle Shona poorly), a way to ground answers in AgriShield's actual data (storage readings, disease scans, weather, prices) rather than hallucinating agronomic advice, and an offline-friendly fallback given the same low-connectivity constraint every other module here takes seriously.
- **Gate before starting:** a specific, named farmer need this would address that SMS/USSD alerts (the Foundation's existing channel) and the app's existing screens don't already cover.

## Idea: a field robot (the Agri-Rover)

Send a navigation robot into a field to carry a disease-screening camera and soil probe, a mechanical weed trimmer, a seed/fertiliser dispenser, and a speaker for the same spoken alerts every other AgriShield module uses — steered down crop rows by retraining the same computer-vision lane-tracking technique on furrows instead of painted lines.

- **Unlike the other two ideas here, this one has a real feasibility signal, not just a wish.** This team already built and demoed a real navigation robot: Campus Compass (also called the Kinetic Directory), a Raspberry Pi 4 + Arduino capstone project with A* pathfinding, ultrasonic/LiDAR obstacle avoidance, and a kiosk it syncs with over MQTT. One of its listed contributors, Mark Chindudzi, is also on the AgriShield team — a genuine link, not an analogy borrowed from someone else's project.
- **Still a multi-year hardware programme, not a near-term build.** Row-tracking vision retrained for furrows instead of painted campus lanes, outdoor weatherproofing, and weeding/seeding attachments are all new engineering on top of Campus Compass, not already-solved problems. Campus Compass itself was only tested on a small, scaled *indoor* course — real field conditions are unverified. Its own documentation also flags that its AA batteries sag under motor load; a field version needs a solar/LiPo power upgrade, not the same batteries, before it needs anything else.
- **Gate before starting:** V1/V2 running long enough to generate real field-health and disease-scan telemetry (Parts 2–3) that a rover would act on — sending a robot to check a spot before there's a reliable signal telling it where to go puts the expensive part first.

## What this document is not

Not a commitment, not a scheduled version, not resourced. Nothing here ships until it has the same evidence-first treatment as V2/V3 — a real gate, a real source, and its limitations stated in the same breath as the feature.
