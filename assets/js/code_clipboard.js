const codeBlocks = document.querySelectorAll("pre");

codeBlocks.forEach(function (codeBlock) {
  const Button = document.createElement("button");
  Button.type = "button";
  Button.ariaLabel = "Copy code to clipboard";
  Button.innerText = "Copy";
  Button.style.position = "absolute";
  Button.style.top = 0;
  Button.style.right = 0;
  Button.style.backgroundColor = "black";
  Button.style.border = "1px solid #535353";
  Button.style.color = "white";
  Button.style.padding = "3px 10px";
  Button.style.fontSize = "14px";

  codeBlock.append(Button);

  Button.addEventListener("click", () => {
    const twoSeconds = 2000;
    const code = codeBlock.querySelector("code").innerText.trim();

    window.navigator.clipboard.writeText(code);

    Button.innerText = "Copied!";

    setTimeout(() => {
      Button.innerText = "Copy";
    }, twoSeconds);
  });
});
