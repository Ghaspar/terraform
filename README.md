# terraform
Exemplos estudados de terraform

# Guia de Primeiros Passos com Terraform

Este guia tem como objetivo te ensinar os primeiros passos com o Terraform: o que é, como instalar e como iniciar um projeto simples.

---

## 📘 O que é Terraform?

Terraform é uma ferramenta open-source da HashiCorp que permite definir e provisionar infraestrutura como código (IaC). Com ele, você consegue automatizar a criação de recursos em nuvens públicas e privadas de forma declarativa.

---

## ⚙️ Pré-requisitos

- Ter o Git instalado
- Ter o `curl` ou `wget` disponível
- Acesso ao terminal (Linux, macOS ou WSL no Windows)

---

## 📥 Instalação do Terraform

### Linux/macOS

```bash
# Baixando a última versão
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Atualizando repositórios e instalando
sudo apt update && sudo apt install terraform -y
```

### Windows

1. Baixe o executável do Terraform: https://developer.hashicorp.com/terraform/downloads
2. Extraia o `.zip` em uma pasta.
3. Adicione a pasta extraída ao `PATH` do sistema.

---

## ✅ Verificando a instalação

```bash
terraform -v
```

O comando deve retornar a versão instalada.

---

## 🚀 Criando seu primeiro projeto Terraform

### 1. Inicie um diretório para seu projeto

```bash
mkdir meu-projeto-terraform
cd meu-projeto-terraform
```

### 2. Crie um arquivo `main.tf`

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "exemplo" {
  bucket = "meu-primeiro-bucket-terraform"
  acl    = "private"
}
```

### 3. Inicialize o projeto

```bash
terraform init
```

### 4. Visualize o que será criado

```bash
terraform plan
```

### 5. Aplique as mudanças

```bash
terraform apply
```

---

## 🧹 Limpando os recursos

```bash
terraform destroy
```

---

## 📚 Documentação oficial

Acesse a documentação oficial do Terraform para aprender mais: https://developer.hashicorp.com/terraform/docs

---

Boa sorte com sua jornada em IaC! 🚀
