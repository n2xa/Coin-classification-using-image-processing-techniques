image = imread("coins.png");
figure;

% Original Image subplot
subplot(2, 3, 1);
imshow(image);
title('Original Image');

% 1.Convert the image to a binary image 
% Allows for clearer separation of the coins from the background.
BinaryImage = im2bw(image);
subplot(2, 3, 2);
imshow(BinaryImage);
title('Binary Image');

%{
2.Fill the holes
After converting the image to a binary, there were gaps within the coins,
filling the holes ensures that each coin is a single connected component,
so that properties are calculated correctly.
%}
filledImage = imfill(BinaryImage, 'holes');
subplot(2, 3, 3);
imshow(filledImage);
title('Filled image (fully connected coins)');

%{
3.Labeling coins 
(LabeledImage) is a 2D matrix that has the same dimensions as the binary
image, where each coin in the binary image is assigned a unique label.

4.Extracting properties
Regionprops is a function that returns a struct (CoinProperties) 
where each element corresponds to a labeled region (coin) in the image.
Since i specified "Area" (representing the number of pixels) and 
"BoundingBox"(a rectangle that encompasses each coin, not visible just 
the coordinates) as properties, these properties are attached for every
coin, providing information about the size and position of each coin in 
the image. 
Area/ i needed it to distinguish between large and small coins
BoudingBox/ it’s used to be the position of a rectangle that i will be putting
in the output image to identify types of coins.
%}

LabeledImage = bwlabel(filledImage);
CoinProperties = regionprops(LabeledImage, 'Area', 'BoundingBox');

% Display the labeled image
subplot(2, 3, 4);
imshow(label2rgb(LabeledImage, 'jet', 'k')); %for visual proposes 
title('Labeled Image');

% subplot for identifying the coins of different area (nickles/dimes)
% and displaying their totals
subplot(2, 3, [5, 6]); 
imshow(image);
hold on

% Initialize counters for nickels and dimes
nickelCount = 0;
dimeCount = 0;

% i displayed each coin and its area ,also it can be seen in CoinProperties
% struct
for n = 1:numel(CoinProperties)
    area = CoinProperties(n).Area;
    fprintf('Coin %d Area: %g\n', n, area);
end

% after i displayed the areas of the coins i selected a value which is 2100
% because it seperates large coins (nickles) from the small ones (dimes) 
% in this example selecting a threshold of values (1892 to 2508) would work.
AreaThreshold = 2100;

for n = 1:numel(CoinProperties) %Looping over the coins
    area = CoinProperties(n).Area; %Extracting the coin(n) area
    boundingBox = CoinProperties(n).BoundingBox; %Extracting the coin(n) position

   %{
      boundingBox is an array of 4 elements. boundingBox(1) is The 
      x coordinate of the top-left corner of the bounding box.
      boundingBox(2) is The y coordinate of the top-left corner 
      of the bounding box.boundingBox(3) is The width of the 
      bounding box. Finally, boundingBox(4) The height 
      of the bounding box.
   %}
    centerX = boundingBox(1) + boundingBox(3) / 2;
    centerY = boundingBox(2) + boundingBox(4) / 2;

    %{
     so for me to find the center x coordinate i calculated the middle point
     between the left and right edges. the same thing goes for y coordinate
     i calculated the middle point between the top and bottom edges.
     i did this so that the text is centered in the output image
    %}


    if area > AreaThreshold %case of Nickles 5 cents (large coins)
        text(centerX, centerY, '5¢', 'Color', 'm', 'FontWeight', 'bold');
        rectangle('Position', boundingBox, 'EdgeColor', 'm', 'LineWidth', 1);
        nickelCount = nickelCount + 1;
    else % case of dimes 10 cents (small coins)
        text(centerX, centerY, '10¢', 'Color', 'b', 'FontWeight', 'bold');
        rectangle('Position', boundingBox, 'EdgeColor', 'b', 'LineWidth', 1);
        dimeCount = dimeCount + 1; 
        
    end
end

hold off

title(sprintf('Total number of coins: %d, Total number of nickels (5¢): %d, Total number of dimes (10¢): %d',numel(CoinProperties),nickelCount, dimeCount));

