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

To solve these, I first dealt with stripping unusual symbols like "+" from fields. Then, I translated all weight fields into 2023 weight classes.

### Assumptions
Many assumptions and simpilfications were made during my cleaning process:
- Since weights were all translated into 2023 weight classes, the ordinal placement of athletes overall may be skewed. The actual best lift numbers do not change, but where they placed in a meet when they competed in a different weight class would. I am not investigating placements, so this is not of concern to me.
- 

### Attribution
This page uses data from the OpenPowerlifting project, https://www.openpowerlifting.org.
You may download a copy of the data at https://gitlab.com/openpowerlifting/opl-data.
