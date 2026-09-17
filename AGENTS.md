# Palm Atoll agent notes

Follow `CLAUDE.md` and `docs/PALM_ATOLL_BUILD_SPEC.md`.
Spec wins. Stricter anti-predatory rule wins ties.
Do not add a Daylight / energy / dice SKU. Do not add a second wallet.
ChanceRng is the only chance source. AiRng is the only poker-decision source.
IAP, shop, spend-cap, VIP events MUST NOT call ChanceRng or mutate its seed.
