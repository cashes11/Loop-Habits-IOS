# 📊 Habit Score System - Explained

## What is the Habit Score?

The **Habit Score** (also called "Habit Strength") is a number between **0%** and **100%** that represents how strong your habit is.

- **0%** = Weak habit, just starting or many missed days
- **100%** = Strong habit, consistently maintained over time

Think of it as your habit's "health bar" 🎮

---

## How It Works

### The Formula

```
score = previousScore × decayMultiplier + todayValue × (1 - decayMultiplier)

where:
  decayMultiplier = 0.5^(√frequency / 13)
```

**In plain English:**
1. Your old score slowly **decays** over time
2. Completing the habit today **boosts** the score
3. Missing days lets it **fade**
4. Long streaks build it **gradually**

### Key Properties

**🐢 Builds Slowly**
- Can't reach 100% overnight
- Takes weeks of consistency
- Rewards long-term commitment

**📉 Decays Gradually**
- Missing one day after a long streak ≠ disaster
- The longer your streak, the slower the decay
- Recovery is possible!

**⚖️ Frequency Matters**
- Daily habits: Decay faster, need daily attention
- Weekly habits: Decay slower, more forgiving
- Custom frequencies: Automatically balanced

---

## Examples

### Daily Meditation Habit (1 time per 1 day)

| Days | Checkmarks | Score | Explanation |
|------|------------|-------|-------------|
| 0 | - | 0% | Just starting |
| 1 | ✓ | 50% | First day boost |
| 2 | ✓ | 75% | Building momentum |
| 7 | ✓✓✓✓✓✓✓ | 91% | One week strong |
| 30 | All ✓ | 99% | Nearly perfect |
| 31 | Miss one | 97% | Small dip, recoverable |

### Weekly Gym Habit (3 times per 7 days)

| Weeks | Completions | Score | Explanation |
|-------|-------------|-------|-------------|
| 0 | - | 0% | Starting |
| 1 | 3/7 days ✓ | 60% | Met weekly goal |
| 4 | All weeks good | 85% | Building strong |
| 8 | Consistent | 95% | Very strong |
| 9 | Only 2/7 this week | 90% | Minor drop |

---

## What the Score Tells You

### 🟢 High Score (70%+)
- ✅ Habit is well-established
- ✅ Part of your routine
- ✅ Keep it up!

**Action:** Maintain consistency, you're doing great!

### 🟡 Medium Score (40-69%)
- ⚠️ Building phase
- ⚠️ Needs more consistency
- ⚠️ Don't give up!

**Action:** Focus on not breaking the chain for 2-3 weeks

### 🔴 Low Score (0-39%)
- ⛔ Struggling or new
- ⛔ Not yet a habit
- ⛔ Needs attention

**Action:** Start small, focus on showing up daily

---

## Score vs. Streak

| Metric | What It Measures | When It's Better |
|--------|------------------|------------------|
| **Streak** | Days in a row without missing | Short-term motivation |
| **Score** | Overall habit strength | Long-term progress |

**Example:**
- You have a 60-day streak → Miss one day → Streak = 0 😢
- You have a 90% score → Miss one day → Score = 88% 😌

**The score is more forgiving and realistic!**

---

## The Math (For the Curious)

### Decay Rate

The decay multiplier depends on frequency:

| Habit Type | Frequency | Decay Multiplier | Meaning |
|------------|-----------|------------------|---------|
| Daily | 1.0 | 0.9279 | 7.2% decay per day |
| 3x/week | 0.428 | 0.9555 | 4.5% decay per day |
| Weekly | 0.143 | 0.9744 | 2.6% decay per day |

**Why this matters:**
- Daily habits need daily attention
- Weekly habits have more breathing room
- The formula adapts automatically!

### Time to Reach 90%

Starting from zero with perfect completion:

- **Daily habit:** ~28 days
- **3x per week:** ~35 days
- **Weekly habit:** ~42 days

**This is why habit formation takes 30+ days!**

---

## How iOS Shows Your Score

### Main List
```
🟠 Meditate              85%
   Did you meditate...
   ○ ○ ○ ● ● ○ ●
```
Small percentage next to habit name

### Detail View
```
Statistics
Habit Strength        92%  ████████████░░
Frequency             1 times every 1 days
Current Streak        12 days
Total Completions     45
```
Large percentage with visual bar

---

## Tips for Improving Your Score

### 1. **Don't Break the Chain**
- Even on hard days, do the minimum
- 5 minutes counts the same as 50 for yes/no habits

### 2. **Recover Quickly from Misses**
- Missed yesterday? Don't miss today!
- One miss ≠ failure
- Get back on track immediately

### 3. **Set Realistic Frequencies**
- Starting? Try 3x/week instead of daily
- Build up gradually
- Success breeds success

### 4. **Use Numerical Habits Wisely**
- Set achievable targets
- 10 minutes is better than 0
- Partial credit helps score

### 5. **Track Long-Term**
- Score shows real progress
- 80%+ means it's becoming automatic
- Don't obsess over daily fluctuations

---

## Understanding Numerical Habits

For numerical habits (e.g., "Run 30 minutes, 3x/week"):

```
Score considers:
- How much you did in the rolling window
- Compared to your target
- Over the frequency period
```

**Example:** Target 30 min, 3x/week
- Week 1: 10, 20, 40 min (70 total) → ~100% that week
- Week 2: 0, 15, 25 min (40 total) → ~45% that week
- Week 3: 30, 30, 30 min (90 total) → 100% that week

Score smooths these out over time!

---

## Comparison with Android App

The iOS score calculation uses **exactly the same formula** as the Android version:

✅ Same decay rate
✅ Same frequency adjustments  
✅ Same numerical habit logic
✅ Same time constants (0.5^(√f/13))

**Your scores will match across platforms!**

---

## Advanced: AT_LEAST vs AT_MOST

### AT_LEAST (default for numerical)
"Do at least X" - More is better
- Running: At least 30 minutes
- Reading: At least 20 pages
- Score = min(1.0, actual/target)

### AT_MOST (for reduction goals)
"Do at most X" - Less is better
- Sugar: At most 25g per day
- Screen time: At most 2 hours
- Score = max(0, 1 - (actual-target)/target)

---

## FAQ

**Q: My score is stuck at 85%, why not 100%?**
A: It approaches 100% asymptotically. Even with perfect completion, it takes 60+ days to exceed 99%.

**Q: I missed one day and lost 10%!**
A: Daily habits decay faster. Weekly habits would only lose ~3%. This is by design.

**Q: Can score go down even if I complete today?**
A: Yes, if your rolling window includes more misses than completions.

**Q: Should I aim for 100%?**
A: 80-90% is excellent! Focus on consistency, not perfection.

**Q: Does skipping affect score?**
A: No! Skipped days are ignored in calculations. Use them for planned breaks.

---

## The Psychology

The score formula was designed to:

1. **Reward consistency** over perfection
2. **Forgive occasional misses** after long streaks
3. **Reflect realistic habit strength**
4. **Encourage long-term thinking**
5. **Avoid discouragement** from one bad day

**It's not about being perfect. It's about being persistent.** 💪

---

## See It In Action

Open your app and:
1. Create a new habit
2. Check it off today → See score jump to ~50%
3. Check tomorrow → Watch it climb to ~75%
4. Keep going for a week → See it approach 90%
5. Miss a day → Notice small dip, not catastrophic
6. Resume → Watch recovery

**The score is your habit's "vital sign" - monitor it, but don't stress over it!**
