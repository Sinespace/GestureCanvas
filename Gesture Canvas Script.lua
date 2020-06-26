
controller = Space.GetResource('controller')
canvas = Space.Host.GetReference('canvas')
mix = Space.Host.GetReference('mix')
fade = Space.Host.GetReference('fade')
exitAnim = Space.GetResource('goodbye')

myPlayer = Space.Scene.PlayerAvatar
myObj = Space.Host.ExecutingObject

channel = channel or 'space.sine.gesturecanvas'
myChannel = channel..'.'..myObj.GlobalID

seated = false
user = nil
userObj = nil

currentAnim = nil
lastAnimTime = {}

mixMode = false
if mix ~= nil then
    mix.UIToggle.IsOn = mixMode
end
fadeMode = false
if fade ~= nil then
    fade.UIToggle.IsOn = fadeMode
end

function sitDown()
    seated = true
    user = myPlayer.ID
    userObj = myPlayer
    canvas.Active = true
    if userObj.Skeleton.Animator.Controller ~= controller then
        userObj.Skeleton.Animator.Controller = controller
    end
    sendNetworkUpdate()
end

function standUp()
    seated = false
    user = nil
    userObj = nil
    canvas.Active = false
    sendNetworkUpdate()
    if exitAnim ~= nil then
        myPlayer.PlayCustomAnimation(exitAnim)
        myPlayer.StopCustomAnimation()
    end
end

function handleMyNetwork(data)
    if data.Message.user ~= myPlayer.ID then
        local olduser = user
        seated = data.Message.seated
        user = data.Message.user
        if user == nil then
            if userObj ~= nil and olduser ~= nil and userObj.ID == olduser then
                userObj.PlayCustomAnimation(exitAnim)
                userObj.StopCustomAnimation()
            end
            userObj = nil
        elseif userObj == nil or userObj.ID ~= user then
            userObj = Space.Scene.GetAvatar(user)
        end
        if userObj ~= nil then
            if userObj.Skeleton.Animator.Controller ~= controller then
                userObj.Skeleton.Animator.Controller = controller
            end
            if data.Message.anim ~= nil then
                if data.Message.mix == true and data.Message.last ~= nil then
                    if data.Message.fade then
                        userObj.Skeleton.Animator.CrossFade(data.Message.anim, 0.3, 0, data.Message.last)
                    else
                        userObj.Skeleton.Animator.Play(data.Message.anim, 0, data.Message.last)
                    end
                else
                    userObj.Skeleton.Animator.CrossFadeInFixedTime(data.Message.anim, 0.3)
                end
            end
        end
        currentAnim = data.Message.anim
    end
end

function sendNetworkUpdate(anim)
    Space.Network.SendNetworkMessage(myChannel, {seated=seated, user=user, anim=anim, last=lastAnimTime[anim], mix=mixMode, fade=fadeMode, sender=myPlayer.ID})
end

function triggerAnim(anim)
    if mix ~= nil then
        mixMode = mix.UIToggle.IsOn
    end
    if fade ~= nil then
        fadeMode = fade.UIToggle.IsOn
    end
    if user == myPlayer.ID then
        if currentAnim ~= nil then
            lastAnimTime[currentAnim] = myPlayer.Skeleton.Animator.GetNormalizedTime(0)
            if lastAnimTime[currentAnim] > 1.0 then
                lastAnimTime[currentAnim] = lastAnimTime[currentAnim] - Space.Math.Floor(lastAnimTime[currentAnim])
            end
            --Space.Log("saving last time of "..lastAnimTime[currentAnim].." for "..currentAnim)
        end
        if mixMode and lastAnimTime[anim] ~= nil then
            --Space.Log("resuming last time of "..lastAnimTime[anim].." for "..anim)
            if fadeMode then
                myPlayer.Skeleton.Animator.CrossFade(anim, 0.3, 0, lastAnimTime[anim])
            else
                myPlayer.Skeleton.Animator.Play(anim, 0, lastAnimTime[anim])
            end
        else
            myPlayer.Skeleton.Animator.CrossFadeInFixedTime(anim, 0.3)
        end
    end
    currentAnim = anim
    sendNetworkUpdate(anim)
end

function anim1() triggerAnim('anim1') end
function anim2() triggerAnim('anim2') end
function anim3() triggerAnim('anim3') end
function anim4() triggerAnim('anim4') end
function anim5() triggerAnim('anim5') end
function anim6() triggerAnim('anim6') end
function anim7() triggerAnim('anim7') end
function anim8() triggerAnim('anim8') end
function anim9() triggerAnim('anim9') end
function anim10() triggerAnim('anim10') end
function anim11() triggerAnim('anim11') end
function anim12() triggerAnim('anim12') end
function anim13() triggerAnim('anim13') end
function anim14() triggerAnim('anim14') end
function anim15() triggerAnim('anim15') end
function anim16() triggerAnim('anim16') end

function handlePlayerLeft(player)
    if player == user then
        seated = false
        user = nil
        userObj = nil
    end
end

function init()
    Space.Network.SubscribeToNetwork(myChannel, handleMyNetwork)

    Space.Scene.OnPlayerLeave(handlePlayerLeft)

    if myObj.Seat ~= nil then
        myObj.Seat.Enabled = true;
    end
end

init()
