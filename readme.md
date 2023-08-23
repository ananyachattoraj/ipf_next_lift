### Intro
3 White Lights is a project about exploring and gaining insights into lifting data of International Powerlifting Federation (IPF) events. Powerlifting competitions judge athletes on their best squat, bench press, and deadlift within their competition sex and weight class. 3 white lights are the gold standard of a lift. (Maybe it should be renamed white standard!) Every lift is judged by 3 judges: left, right, center. Each judge, then, white-lights or red-lights the lift based on the [IPF Technical Rulebook](https://www.powerlifting.sport/fileadmin/ipf/data/rules/technical-rules/english/IPF_Technical_Rules_Book_2022_1.pdf). A lift getting 3 white lights means that the judges have unanimously agreed the lift counts and is a good lift.

Like any sport, a lot goes into strategizing for the best results. Every lifter gets 3 attempts at the 3 lifts. This means that there are often weight changes by the third attempt of each lift (especially on the deadlift as it closes out the competition day). Every attempt builds fatigue, so choosing the correct next attempt can make or break an athlete's day. Using this as the starting point, I begin to analyze the data of the IPF.

The main questions I aim to tackle in this project are:
- What are the trends in lift numbers by sex/weight class at competition?
- Does meet location influence demographics of competitors?
- How might we assist coaches and lifters in determining their next competition lift attempts?

### Process
This data was first loaded into Python for initial feature exploration. In this initial exploration, I considered which columns to drop and which flagged which columns would require augmentation like data imputation or field formatting changes. After some very initial column dropping, I created a schema for the dataset in SQL and loaded the data into SQL!

At this point, I was faced with the messy truth of messy data. Very messy data. Here's some issues I dealt with:
- Weight classes have changed multiple times over the course of the IPF. Furthermore, weight classes entered by meet recorders don't always follow IPF weight classes. Not all numbers entered were in fact numbers (symbols like "+" were included).
- Age recording is inaccurate. The age field uses a decimal marker when the age is approximated, the age class field usage differs by sub-federation, and birth year field is missing information.
- Missing attempts. Some meet records only include the best lift without recording attempts, and sometimes, attempts are recorded but the best lifts aren't recorded.

To solve these, I first dealt with stripping unusual symbols like "+" from fields. Then, I translated all weight fields into 2023 weight classes. Then, using all other age fields, I imputed birth year classes (since that is most used by IPF).

Further quick analyses were performed in SQL and then visualizations were created in Tableau.

### Overarching Assumptions
- Since weights were all translated into 2023 weight classes, the ordinal placement of athletes overall may be skewed. The actual best lift numbers do not change, but where they placed in a meet when they competed in a different weight class would. I am not investigating placements, so this is not of concern to me.
- Super heavy weight classes (84+ for women and 120+ for men) were coded as "840" and "1200" since special symbols could not be used and weight classes are commonly referred to using the high-end of the class.

### Initial Findings

#### Trends
I investigated the trends in bench press numbers among women. I investigated this in particular because of gendered stereotypes around women focusing on lower body work and men focusing on upper body work. In recent years, the bench press has bloomed among women's powerlifting communities with the rise of outlier athletes like [Jennifer Thompson](https://www.openpowerlifting.org/u/jenniferthompson1) and [Agata Sitko](https://www.openpowerlifting.org/u/agatasitko).

![Average Best Bench (raw) for Women 2011+](https://github.com/ananyachattoraj/ipf_next_lift/assets/15469141/b4a310f4-a157-4cd6-8b0d-f5e2931d16a9)

Note that I restricted this visual to 2011+ since there was a major weight class shuffle in 2010 by the IPF. Since this visual is divided by weight class, the major weight class shuffle would not have appropriately represented the trends. The 2023 weight class shift was comparatively smaller (changing just 1 weight class), so I didn't feel the need to account for that.

Since 2023 is not over at the time of analysis and meet records may come in with a time lag, we may discount that when looking at a general trend, but it is interesting to have at the back of our minds. We see that there is a general trend suggesting increasing bench press weights. Interestingly, we see that higher weight classes have smaller differentials between average best bench press numbers. Note that athletes will sometimes fluctuate between weight classes either for personal reasons or for strategy. This may explain sharp bumps or dips in the visual.

#### Geographies and Demographics
Next, I investigated the percentage of women both by country of affiliation and by meet country. Again, I focused on women due to gendered expectations around strength sport competitions. I wanted to investigate two things: whether there were seeming dead zones among regions where meets occur, and whether there were regions where women in particular had less meet involvement even though there were women lifters in those regions.

![% of Women Competitors By Lifter Country](https://github.com/ananyachattoraj/ipf_next_lift/assets/15469141/f7f7b8b7-3a47-416b-b5a7-d21bc818bbb4) 
![% of Women Competitors By Meet Country](https://github.com/ananyachattoraj/ipf_next_lift/assets/15469141/1e111339-6da4-4aff-b88a-39cad0674bf6)

We now draw a few insights. There are comparatively fewer women lifters from African and SWANA countries than in most other regions of the world. This may be due to differing gender roles in these regions, but also, it may be due to a lack of awareness of the federation within the sport. This data only accounts for IPF meets (the largest international federation). There are other federations across the world, and it may be the case that other federations are locally more popular.

Next, we see that the countries where meets occur are far fewer than the countries from which lifters hail. This is unsurprising since meets take organization and planning, so they are better suited to more central locations or locations where there are large nexuses of lifters. 

It is interesting to note, however, that some countries like China see a dip in the proportion of women lifters actually competing within the country than the proportion who claim to be from there. There may be several reasons for dips like this, one of which may be that traveling for a competition is seen as an "event" in an athlete's life, so international meets may be valued more while local meets are used only as qualifiers.

#### Score Types
Since powerlifting is a weight class sport, it may become difficult to compare lifts across weight classes and across competition sex. This is a known concern among the strength community and online tools (like [Symmetric Strength](https://symmetricstrength.com/)) that categorize a lifter's ability by normalizing those factors have become popular among strength enthusiasts. This is not simply a concern in the enthusiast community, but also in competition. The Best Lifter award is given to lifters who have the highest Goodlift points (formerly IPF score) across weight classes but segmented by competition sex. Goodlift points are not the first attempt to normalize across weights and competition sex. Previous attempts have included Wilks score (still very popular), Dots, and Glossbrenner. The aim of a score is to ensure that no particular weight class or gender is underscored or overscored such that a comparison across these factors is possible.

Given this aim of the different score types, I investigated the distribution of scores across weight classes and competition sex (excluding Mx sex for low sample size) to determine which score showed the most promise in reaching its aim.

![Distribution of Average Scores by Weight Class + Score Type](https://github.com/ananyachattoraj/ipf_next_lift/assets/15469141/bb085034-7d2e-4582-a06f-5558a31de971)

We see that all score types underscore low weight classes. Note that since the 43KG and 53KG are only weight classes in the sub-junior or junior age ranges (<24 yrs of age), their sample sizes are significantly smaller than the other weight classes that can contain lifters of any age. So, the discrepancy may be due to sample size. Statistical significance of the discrepancies will be calculated in future investigations.

It is interesting to note that Goodlift points have the most even distribution among weight classes of women, but are outperformed in equity of distribution by other score types for men. It may also simply be the case that constructing a score to represent the men's weight classes is more challenging since there is a greater range in weights reflected in the men's weight classes despite there being the same number of weight classes across genders. There has been talk within the wider community about hoping for a 92KG weight class for women, which may change the distribution of the women's scores to something closer to the men's.

### Parting Thoughts
There are still further investigations that I plan to conduct using this data, including the construction of a predictive model to assist the choice of a next lift.

If at this point, you're wondering what my lift numbers are, I'm only an enthusiast and a post on the barrier to IPF regulated competition would be out of the scope of a data analysis. Still, my gym numbers are as follows:

At a bodyweight of 120lbs/54.5KG:
- Squat: 250lb/113.4KG
- Bench: 150lb/68KG
- Deadlift: 300lb/136KG

It does feel nice that my bench is above average for the weight class that I would be in, but of course, the pressures of a competition can affect even the best lifter, of which, I certainly am not (yet).

### Attribution
This page uses data from the OpenPowerlifting project, https://www.openpowerlifting.org.
You may download a copy of the data at https://gitlab.com/openpowerlifting/opl-data.
