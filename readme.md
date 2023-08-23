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


### Attribution
This page uses data from the OpenPowerlifting project, https://www.openpowerlifting.org.
You may download a copy of the data at https://gitlab.com/openpowerlifting/opl-data.
