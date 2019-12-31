use ipl;
show tables;

select * from ipl_bidding_details;
select * from ipl_match_schedule;
select * from ipl_team;

-- 1)
SELECT B1.BIDDER_ID, CONCAT(COUNT(B1.BID_STATUS)/(SELECT COUNT(B2.BID_STATUS) FROM IPL_BIDDING_DETAILS B2 WHERE B1.BIDDER_ID=B2.BIDDER_ID GROUP BY B2.BIDDER_ID )*100) AS PERCENTAGE
FROM IPL_BIDDING_DETAILS  B1 WHERE B1.BID_STATUS = 'WON' GROUP BY B1.BIDDER_ID ORDER BY PERCENTAGE DESC;

-- 2)
select team_name,
case
when team_id = (select bid_team from ipl_bidding_details group by bid_team order by count(bid_team) desc limit 1) then 'highest'
when team_id = (select bid_team from ipl_bidding_details group by bid_team order by count(bid_team) limit 1) then 'lowest'
end as 'no of bids'
from ipl_team where 'no of bids' is not null;

-- 3)
select stadium_name, mat.toss_winner, (count(mat.match_winner)/(select count(mat2.toss_winner) from ipl_match mat2 where mat2.toss_winner = mat.toss_winner group by stadium_name,toss_winner)*100)  as percentage
from ipl_match_schedule sch join ipl_stadium std
on sch.stadium_id = std.stadium_id
join ipl_match mat
on mat.match_id = sch.match_id
group by stadium_name, mat.toss_winner
having (stadium_name,mat.toss_winner) in (select stadium_name,toss_winner from ipl_match where match_winner = mat.toss_winner group by stadium_name,toss_winner);

-- 4)
select its.team_id, count(ibd.bid_team) 
from ipl_team_standings its join ipl_bidding_details ibd
group by its.team_id
having its.team_id = (select team_id from ipl_team_standings order by matches_won desc limit 1);

-- 5)
select its2.total_points - its1.total_points, its1.team_id, it.team_name
from ipl_team_standings its1 join ipl_team_standings its2
on its1.team_id = its2.team_id
join ipl_team it
on it.team_id = its1.team_id
where its1.tournmt_id = 2017
and its2.tournmt_id = 2018
and its1.tournmt_id <> its2.tournmt_id
and (its2.total_points - its1.total_points) > 0
group by team_id order by 1 desc limit 1;
