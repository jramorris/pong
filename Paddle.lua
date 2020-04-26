--[[
    GD50 2018
    Pong Remake

    -- Paddle Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents a paddle that can move up and down. Used in the main
    program to deflect the ball back toward the opponent.
]]

Paddle = Class{}

--[[
    The `init` function on our class is called just once, when the object
    is first created. Used to set up all variables in the class and get it
    ready for use.

    Our Paddle should take an X and a Y, for positioning, as well as a width
    and height for its dimensions.

    Note that `self` is a reference to *this* object, whichever object is
    instantiated at the time this function is called. Different objects can
    have their own x, y, width, and height values, thus serving as containers
    for data. In this sense, they're very similar to structs in C.
]]
function Paddle:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dy = 0
    self.predictedY = nil
end

function Paddle:update(dt)
    -- math.max here ensures that we're the greater of 0 or the player's
    -- current calculated Y position when pressing up so that we don't
    -- go into the negatives; the movement calculation is simply our
    -- previously-defined paddle speed scaled by dt
    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)
    -- similar to before, this time we use math.min to ensure we don't
    -- go any farther than the bottom of the screen minus the paddle's
    -- height (or else it will go partially below, since position is
    -- based on its top left corner)
    else
        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
    end
end

--[[
    To be called by our main function in `love.draw`, ideally. Uses
    LÖVE2D's `rectangle` function, which takes in a draw mode as the first
    argument as well as the position and dimensions for the rectangle. To
    change the color, one must call `love.graphics.setColor`. As of the
    newest version of LÖVE2D, you can even draw rounded rectangles!
]]
function Paddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

--[[
    Predict where ball.y will be when it hits Paddle1.
    It needs to take into account the fact that the paddles aren't at the edge of the screen.
    They're actually a few pixels in.
]]
--[[
function Paddle:predictor(ball)
    if ball.dy ~= 0 then
        slope = ball.dy / ball.dx
        if slope > 0 then
            directionality = 1
        else
            directionality = -1
        end
        xDiff = VIRTUAL_WIDTH - ball.shiftX -- num diff x at end of screen
        yIntercept = ball.shiftY + (ball.height / 2 + 1)
        predictedY = (slope * xDiff) + yIntercept + (5 * directionality)

        if predictedY < 0 then
            -- next, calc X when Y == 0
            shiftX = -yIntercept / slope
            slope = -slope -- slope inverses after hitting roof
            xDiff = VIRTUAL_WIDTH - shiftX -- num diff x at end of screen
            predictedY = (slope * xDiff) - 10
        elseif predictedY > VIRTUAL_HEIGHT then
            -- next, calc X when Y == Virt Height
            shiftX = (VIRTUAL_HEIGHT - yIntercept) / slope
            slope = -slope -- slope inverses after hitting floor
            xDiff = VIRTUAL_WIDTH - shiftX -- num diff x at end of screen
            predictedY = (slope * xDiff) + VIRTUAL_HEIGHT + 10
        end
        return predictedY
    else
        return VIRTUAL_HEIGHT / 2 - self.height / 2
    end
end
]]

function Paddle:predictorTwo(dy, dx, shiftY, shiftX)
    print(string.format("dx: %s; dy: %s; shiftY; %s; shiftX: %s;", dx, dy, shiftY, shiftX))
    game_width = VIRTUAL_WIDTH - 10 - BALL_WIDTH
    if dy ~= 0 then
        slope = dy / dx
        deltaX = game_width - shiftX
        yInt = shiftY
        print(string.format("slope: %s; deltaX: %s; yInt: %s;", slope, deltaX, yInt))
        y = (slope * deltaX) + yInt
        if y < 0 or y > VIRTUAL_HEIGHT then
            if slope > 0 then
                hitFloor = (VIRTUAL_HEIGHT - shiftY) / slope
                return self:predictorTwo(-dy, dx, VIRTUAL_HEIGHT, hitFloor)
            else
                hitRoof = (-1.5 - shiftY / slope)
                print(string.format("predX when collided: %s", hitRoof))
                return self:predictorTwo(-dy, dx, 0, hitRoof)
            end
        else
            print(string.format("Predicted Y: %s", y))
            return y
        end
    else
        return VIRTUAL_HEIGHT / 2 - self.height / 2
    end
end
