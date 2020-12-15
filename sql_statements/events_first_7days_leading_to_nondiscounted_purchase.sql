with initial_dataset as (
  select
    case 
      when event_name like 'sv__OnBoardingTutorialVi%' then 'sv__OnBoardingTutorialView'
      else event_name
    end as event_name,
    optional_label,
    event_timestamp,
    event_date,
    user_id,
    user_pseudo_id,
    ga_session_id,
    user_history_event_number,
    session_event_number,
    platform,
    device_language,
    country
  from
    analytics_151430920.firebase_facts_events as eve
  where
    eve.event_timestamp >= '2020-11-01'
  and
    eve.event_name in ('sv__OnBoardingTutorialVi','sv__WelcomeCarouselDialog','sv__NewPremiumAct','TryToBuyNewPAct','TryToBuyNewPF','ClickOnWholeView','StartListening','sv__StoryDetails','StartNStory','StartBekids','FabClickedPremium','PremiumBarClickedSD','PremiumBarClickedMain','sv__AAPageA','sv__ProPageA','sv_GoldPageA','sv__AAPageF','sv__ProPageF','sv__GoldPageF','EnterFcMore','sv__GlossaryF','LibraryClicked','sv__Libraries','PlayPrevParagraph','PlayNextParagraphFromBut','sv__OnBoardingTutorialVie','in_app_purchase','PurchaseNormal')
),   

premium_promo_shown as (
  select distinct
    user_pseudo_id,
    first_value(event_timestamp) over (partition by user_pseudo_id order by event_timestamp) as first_premium_promo_shown_timestamp
  from
    initial_dataset
  where
    event_name = 'sv__WelcomeCarouselDialog'
),

purchases as (
  select distinct
    'in_app_purchase' as event_name,
    first_value(event_timestamp) over (partition by user_pseudo_id order by event_timestamp) as first_purchase_timestamp,
    first_value(event_date) over (partition by user_pseudo_id order by event_timestamp) as first_purchase_date,
    first_value(optional_label) over (partition by user_pseudo_id order by event_timestamp) as optional_label,
    last_value(user_id) over (partition by user_pseudo_id order by event_timestamp) as user_id,
    user_pseudo_id,
    first_value(ga_session_id) over (partition by user_pseudo_id order by event_timestamp) as ga_session_id,
    first_value(user_history_event_number) over (partition by user_pseudo_id order by event_timestamp) as user_history_event_number,
    first_value(session_event_number) over (partition by user_pseudo_id order by event_timestamp) as session_event_number,
    first_value(platform) over (partition by user_pseudo_id order by event_timestamp) as platform,
    first_value(device_language) over (partition by user_pseudo_id order by event_timestamp) as device_language,
    first_value(country) over (partition by user_pseudo_id order by event_timestamp) as country
  from
    initial_dataset
  where
    event_name in ('in_app_purchase','PurchaseNormal')
),

relevant_purchases as (
  select
    pu.event_name,
    pu.first_purchase_timestamp,
    pu.first_purchase_date,
    ps.first_premium_promo_shown_timestamp,
    pu.optional_label,
    pu.user_id,
    pu.user_pseudo_id,
    pu.ga_session_id,
    pu.user_history_event_number,
    pu.session_event_number,
    pu.platform,
    pu.device_language,
    pu.country
  from
    purchases as pu
  join
    premium_promo_shown as ps on ps.user_pseudo_id = pu.user_pseudo_id
  where
    pu.first_purchase_timestamp > timestamp_add(ps.first_premium_promo_shown_timestamp, interval 30 minute)
),

relevant_events as (
  select
    ini.event_name,
    ini.event_timestamp,
    ini.event_date,
    ini.optional_label,
    ini.user_id,
    ini.user_pseudo_id,
    ini.ga_session_id,
    ini.user_history_event_number,
    ini.session_event_number,
    ini.platform,
    ini.device_language,
    ini.country
  from
    initial_dataset as ini
  left join
    premium_promo_shown as ps on ps.user_pseudo_id = ini.user_pseudo_id
  where
    event_name != 'in_app_purchase'
  and
    ini.event_timestamp between ps.first_premium_promo_shown_timestamp and timestamp_add(first_premium_promo_shown_timestamp, interval 7 day)
  union all
  select
    rep.event_name,
    rep.first_purchase_timestamp as event_timestamp,
    rep.first_purchase_date as event_date,
    rep.optional_label,
    rep.user_id,
    rep.user_pseudo_id,
    rep.ga_session_id,
    rep.user_history_event_number,
    rep.session_event_number,
    rep.platform,
    rep.device_language,
    rep.country
  from
    relevant_purchases as rep
  where
    rep.first_purchase_timestamp between rep.first_premium_promo_shown_timestamp and timestamp_add(rep.first_premium_promo_shown_timestamp, interval 7 day)
)

select
  user_pseudo_id,
  event_name,
  platform,
  country,
  device_language,
  count(event_timestamp) as occurrences_count,
  min(event_timestamp) as first_event_timestamp,
  max(event_timestamp) as last_event_timestamp
from
  relevant_events
group by 1,2,3,4,5;
