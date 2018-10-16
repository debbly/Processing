/*
Copyright (c) 2018 Debbie Ly
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)

Controls:
- Left-click to refresh.

Color schemes:
- "(◕ ” ◕)" by sugar!: http://www.colourlovers.com/palette/848743
- "vivacious" by plch: http://www.colourlovers.com/palette/557539/vivacious
- "Sweet Lolly" by nekoyo: http://www.colourlovers.com/palette/56122/Sweet_Lolly
- "Pop Is Everything" by jen_savage: http://www.colourlovers.com/palette/7315/Pop_Is_Everything
- "it's raining love" by tvr: http://www.colourlovers.com/palette/845564/its_raining_love
- "A Dream in Color" by madmod001: http://www.colourlovers.com/palette/871636/A_Dream_in_Color
- "Influenza" by Miaka: http://www.colourlovers.com/palette/301154/Influenza
- "Ocean Five" by DESIGNJUNKEE: http://www.colourlovers.com/palette/1473/Ocean_Five
- "holographic textures" by Espectro Luminoso: https://www.colourlovers.com/palette/4603445/holographic_textures
- "peacock feather" by CintaLangka: https://www.colourlovers.com/palette/4603418/Peacock_Feather
- "Blue Orange Business" by itcmarcomm: https://www.colourlovers.com/palette/4603218/Blue_Orange_Business
*/

String paletteFileName = "color_palette";

float scale = 1;
int steps = 200;
boolean pause = false;
boolean ignoreWidth = true;

ArrayList<Palette> palettes = new ArrayList<Palette>();
Palette currentPalette;

ArrayList<Integer> chosenColors;

void setup()
{
  int originalWidth = 640;
  int originalHeight = 640;
  int desiredWidth = 640;
  int desiredHeight = 640;
  size(640, 640, P2D);
  scale = min((float)desiredWidth / originalWidth, (float)desiredHeight / originalHeight);
  
  blendMode(ADD);
  
  loadPalettes();

  reset(false);
}

void mouseClicked()
{
  if (mouseButton == LEFT)
  {
    reset(false);
  }
  else if (mouseButton == CENTER)
  {
  }
  else if (mouseButton == RIGHT)
  {
    reset(true);
  }
}

void reset(boolean keepHue)
{
  if (!keepHue)
  {
    int paletteIndex = (int)random(palettes.size());
    currentPalette = palettes.get(paletteIndex);
  }
  
  background(0);
  stroke(currentPalette.colors.get((int)random(0, currentPalette.colors.size())), 5);
  
  pause = false;
}

void draw()
{
  if (pause)
    return;
  
  background(0);
  
  for (int i = 0; i < 2; i++)
    drawGraph();
    
  pause = true;
}

void drawGraph()
{
  int factor = (int)random(2, 10)*3;
  float radiusMin = width/8;
  float radiusMax = height/5;
  int stepsFrom = 1;
  int stepsTo = 15;
  ArrayList<Pendulum> pendulums = new ArrayList<Pendulum>();
  for (int i = 0; i < 5; i++)
  {
    int steps = factor * (int)random(stepsFrom, stepsTo+1);
    if (i == 0)
    {
      pendulums.add(new PendulumDirectional(steps, new PVector(radiusMin, 0)));
    }
    else if (i == 1)
    {
      pendulums.add(new PendulumDirectional(steps, new PVector(0, radiusMax)));
    }
    else if (i == 2)
    {
      pendulums.add(new PendulumRotate(steps));
    }
    else if (i == 3)
    {
      float from = 0;
      float to = 1;
      if (random(1) > 0.5)
        pendulums.add(new PendulumScale(steps, from, to));
    }
    else if (i == 4)
    {
      float from = 0;
      float to = 1;
      if (random(1) > 0.5)
        pendulums.add(new PendulumScale(steps, to, from));
    }
  }
  
  long stepCount = 0;
  boolean allPendulumsZero;
  do
  {
    stepCount++;
    allPendulumsZero = true;
    for (Pendulum pendulum : pendulums)
    {
      pendulum.currentStep = (pendulum.currentStep + 1) % pendulum.steps;
      allPendulumsZero &= pendulum.isZero();
    }
  } while (!allPendulumsZero);
  
  float p = random(0, 1);
  int desiredCount = (int)lerp(10000, 20000, p);
  factor = ceil(desiredCount/stepCount);

  if (factor > 1)
  {
    for (Pendulum pendulum : pendulums)
    {
      pendulum.steps *= factor;
    }
  }
  
  color c = currentPalette.randomColor();
  float a = lerp(random(50, 100), random(1, 20), p)/4;
  fill(c, a);
  c = currentPalette.randomColor();
  stroke(c, a);

  strokeWeight(random(1, 3));
  
  do
  {
    allPendulumsZero = true;
    PVector position = new PVector(0, 0);
    for (Pendulum pendulum : pendulums)
    {
      position = pendulum.step(position);
      allPendulumsZero &= pendulum.isZero();
    }
    float x = width/2 + position.x;
    float y = height/2 + position.y;

    stroke(c, a); noFill();
    line(width/2, height/2, x, y);
  } while (!allPendulumsZero);

  strokeWeight(1);

  c = currentPalette.randomColor();
  stroke(c, 30);

  beginShape();
  vertex(width/2, height/2);
  do
  {
    allPendulumsZero = true;
    PVector position = new PVector(0, 0);
    for (Pendulum pendulum : pendulums)
    {
      position = pendulum.step(position);
      allPendulumsZero &= pendulum.isZero();
    }
    float x = width/2 + position.x;
    float y = height/2 + position.y;
    vertex(x, y);
  } while (!allPendulumsZero);
  endShape();
}

PVector randomDirectionStep(float maxDistance)
{
  return new PVector(random(-maxDistance, maxDistance), random(-maxDistance, maxDistance));
}

PVector randomDirectionRadius(float radius)
{
  float angle = random(0, PI*2);
  return new PVector(sin(angle) * radius, cos(angle) * radius);
}

abstract class Pendulum
{
  public int steps;
  public int currentStep;
  
  public Pendulum(int steps)
  {
    this.steps = steps;
  }
  
  public PVector step(PVector position)
  {
    currentStep = (currentStep+1) % steps;
    return result(position);
  }
  
  protected abstract PVector result(PVector position);
  
  public boolean isZero()
  {
    return currentStep == 0;
  }
  
  public float currentPercent()
  {
    return (float)currentStep / steps;
  }
  
  public float currentPercentSin()
  {
    return sin(currentPercent() * PI * 2);
  }

  public float currentPercentSinHalf()
  {
    return sin(currentPercent() * PI);
  }
}

class PendulumDirectional extends Pendulum
{
  public PVector delta;
  
  public PendulumDirectional(int steps, PVector delta)
  {
    super(steps);
    this.delta = delta;
  }
  
  @Override
  protected PVector result(PVector position)
  {
    float percent = currentPercentSinHalf();
    return PVector.add(position, new PVector(delta.x * percent, delta.y * percent));
  }
}

class PendulumRotate extends Pendulum
{
  public PendulumRotate(int steps)
  {
    super(steps);
  }
  
  @Override
  protected PVector result(PVector position)
  {
    float percent = currentPercent();
    float distance = position.mag();
    float angle = atan2(position.y, position.x) + percent * PI * 2;
    return new PVector(cos(angle) * distance, sin(angle) * distance);
  }
}

class PendulumScale extends Pendulum
{
  float from;
  float to;
  
  public PendulumScale(int steps, float from, float to)
  {
    super(steps);
    this.from = from;
    this.to = to;
  }
  
  @Override
  protected PVector result(PVector position)
  {
    float percent = currentPercentSin();
    float distance = position.mag() * lerp(from, to, percent);
    float angle = atan2(position.y, position.x);
    return new PVector(cos(angle) * distance, sin(angle) * distance);
  }
}


void loadPalettes()
{
  XML xml = loadXML(paletteFileName + ".xml");
  XML[] children = xml.getChildren("palette");
  for (XML child : children)
  {
    Palette palette = new Palette();
    XML[] xcolors = child.getChild("colors").getChildren("hex");
    String[] widths = null;
    if (!ignoreWidth)
      widths = child.getChild("colorWidths").getContent().split(",");
    String title = child.getChild("title").getContent();
    palette.name = title;
    int i = 0;
    for(XML xcolor : xcolors)
    {
      color c = unhex("FF" + xcolor.getContent());
      float w = 1;
      if (widths != null)
        w = Float.parseFloat(widths[i]);
      i++;
      palette.addColor(c, w);
    }
    
    palette.addColor(color(0, 0, 0), 0.2);
    
    palettes.add(palette);
  } 
}

class Palette
{
  ArrayList<Integer> colors = new ArrayList<Integer>();
  ArrayList<Float> widths = new ArrayList<Float>();
  float totalWidth = 0;
  String name;
  
  void addColor(color c, float w)
  {
    colors.add(c);
    widths.add(w);
    totalWidth += w;
  }
  
  color randomColor()
  {
    if (colors.size() == 0)
      return color(0, 0, 0, 0);
    
    float value = random(totalWidth);
    int index = 0;
    while ((index + 1) < colors.size())
    {
      float currentWidth = widths.get(index);
      if (value < currentWidth)
        break;

      value -= widths.get(index);
      index++;
    }
    
    return colors.get(index);
  }
}

int clamp(int value, int min, int max)
{
  return max(min, min(value, max));
}

float mapClamp(float value, float start1, float stop1, float start2, float stop2)
{
  value = max(start1, min(value, stop1));
  return map(value, start1, stop1, start2, stop2);
}
