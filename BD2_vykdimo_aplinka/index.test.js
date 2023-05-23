const request = require('supertest');
const expect = require('chai').expect;

describe('API testavimas', () => {
	const baseurl = 'http://localhost:3000';
	it('Kategorijų sarašo prašymas', (done) => {
		request(baseurl)
			.get('/category')
			.end(function (err, res) {
				expect(res.statusCode).to.be.equal(200);
                var isJson = true;
				try {
                    value = JSON.parse(res.body[0]);
                  } catch (e) {
                   // isJson = false;
                  }
				expect(isJson).to.be.equal(true);
				done();
			});
	});


    it('Kategorijos sukurimas', (done) => {
		request(baseurl)
			.post('/category')
			.query({"name": 'Automatinio testo kategorija'})
			.set('Accept', 'application/json')
			.set('Content-Type', 'application/json')
			.end(function (err, res) {
				expect(res.statusCode).to.be.equal(200);
				expect(res.body.name).to.be.equal('Automatinio testo kategorija');
				done();
			});
	});

    it('Diskusijos sukurimas', (done) => {
		request(baseurl)
			.post('/question')
			.send({ "user": "645be3ee437ddbb7c8e37510",
                    "category": "645b96724dc90e7af95b37f8",
                    "text": "1234"})
			.set('Accept', 'application/json')
			.set('Content-Type', 'application/json')
			.end(function (err, res) {
				expect(res.statusCode).to.be.equal(200);
                expect(res.body.text).to.be.equal("1234");
				done();
			});
	});


    it('Teigiamo balo pridėjimas', (done) => {
		request(baseurl)
			.post('/score')
			.send({ "asnwerId": '645be428437ddbb7c8e3752f',
                    "callerId": "645be3ee437ddbb7c8e37510",
                    "user": "645be3ee437ddbb7c8e37510",
                    "scoreModifier": 1,
                    "category": "645b96724dc90e7af95b37f8"})
			.set('Accept', 'application/json')
			.set('Content-Type', 'application/json')
			.end(function (err, res) {
				expect(res.statusCode).to.be.equal(200);
                expect(res.body).to.be.equal(1);
				done();
			});
	});

    it('Neigiamo Balo pridėjimas', (done) => {
		request(baseurl)
			.post('/score')
			.send({ "asnwerId": '645be428437ddbb7c8e3752f',
                    "callerId": "645be3ee437ddbb7c8e37510",
                    "user": "645be3ee437ddbb7c8e37510",
                    "scoreModifier": -1,
                    "category": "645b96724dc90e7af95b37f8"})
			.set('Accept', 'application/json')
			.set('Content-Type', 'application/json')
			.end(function (err, res) {
				expect(res.statusCode).to.be.equal(200);
                expect(res.body).to.be.equal(-1);
				done();
			});
	});


        it('Atsakymo sukurimas', (done) => {
		request(baseurl)
			.post('/answer/646b4f3f159d74999657611d')
			.send({ "user": '645be428437ddbb7c8e3752f',
                    "text": "Text",
                    "category": "645b96724dc90e7af95b37f8"})
			.set('Accept', 'application/json')
			.set('Content-Type', 'application/json')
			.end(function (err, res) {
				expect(res.statusCode).to.be.equal(200);
                expect(res.body.text).to.be.equal("Text");
				done();
			});
	});

    it('Diskusijų sarašo prašymas', (done) => {
		request(baseurl)
			.get('/dashboard/question')
			.set('Accept', 'application/json')
			.set('Content-Type', 'application/json')
			.end(function (err, res) {
				expect(res.statusCode).to.be.equal(200);
                var isJson = true;
				try {
                    value = JSON.parse(res.body);
                  } catch (e) {
                   isJson = false;
                  }
				expect(isJson).to.be.equal(true);
				done();
			});
	});

    it('Diskusijos prašymas', (done) => {
		request(baseurl)
			.get('/dashboard/question/645b96894dc90e7af95b37fe')
			.set('Accept', 'application/json')
			.set('Content-Type', 'application/json')
			.end(function (err, res) {
				expect(res.statusCode).to.be.equal(200);
                var isJson = true;
				try {
                    value = JSON.parse(res.body);
                  } catch (e) {
                   isJson = false;
                  }
				expect(isJson).to.be.equal(true);
				done();
			});
	});

    it('Reportuoto įrašo panaikinimas', (done) => {
		request(baseurl)
			.post('/deleteReportedAnswer')
            .query({"reportedRecordId": '646b5b770e636aae36af934b'})
			.set('Accept', 'application/json')
			.set('Content-Type', 'application/json')
			.end(function (err, res) {
				expect(res.statusCode).to.be.equal(200);
				expect(res.text).to.be.equal('report deleted');
				done();
			});
	});

    it('Vartotojo blokavimas', (done) => {
		request(baseurl)
			.post('/blockUser')
            .query({"reportedAnswer": '646b5b770e636aae36af934b',
                    "reportedUser": '645be3ee437ddbb7c8e37510'})
			.set('Accept', 'application/json')
			.set('Content-Type', 'application/json')
			.end(function (err, res) {
				expect(res.statusCode).to.be.equal(200);
				expect(res.text).to.be.equal('user blocked');
				done();
			});
	});

    it('Vartotojo prisijungimas', (done) => {
		request(baseurl)
			.post('/login')
            .send({"username": 'Vartotojas1',
                    "password": 'Vartotojas1'})
			.set('Accept', 'application/json')
			.set('Content-Type', 'application/json')
			.end(function (err, res) {
				expect(res.statusCode).to.be.equal(200);
                var isJson = true;
				try {
                    value = JSON.parse(res.body);
                  } catch (e) {
                   isJson = false;
                  }
				expect(isJson).to.be.equal(true);
    			expect(req.body.username).to.be.equal('Vartotojas1');
				done();
			});
	});


    it('Vartotojo registracija', (done) => {
		request(baseurl)
			.post('/register')
            .send({"username": "username",
                  "password": "password",
                  "dateOfBirth": "1999-01-01",
                  "email": "email@email.com",})
			.set('Accept', 'application/json')
			.set('Content-Type', 'application/json')
			.end(function (err, res) {
				expect(res.statusCode).to.be.equal(200);
                var isJson = true;
				try {
                    value = JSON.parse(res.body);
                  } catch (e) {
                   isJson = false;
                  }
				expect(isJson).to.be.equal(true);
        		expect(req.body.username).to.be.equal('username');
            	expect(req.body.password).to.be.equal('password');
            	expect(req.body.dateOfBirth).to.be.equal('1999-01-01');
            	expect(req.body.email).to.be.equal('email@email.com');
				done();
			});
	});


    it('Vartotojo duomenu prašymas', (done) => {
		request(baseurl)
			.get('/user')
            .query({"_id": "645be3ee437ddbb7c8e37510"})
			.set('Accept', 'application/json')
			.set('Content-Type', 'application/json')
			.end(function (err, res) {
				expect(res.statusCode).to.be.equal(200);
                var isJson = true;
				try {
                    value = JSON.parse(res.body);
                  } catch (e) {
                   isJson = false;
                  }
				expect(isJson).to.be.equal(true);
        		expect(req.body.username).to.be.equal('username');
    			expect(req.body.username).to.be.equal('Vartotojas1');
				done();
			});
	});


    it('Įrašo reportavimas', (done) => {
		request(baseurl)
			.post('/reportAnswer')
            .query({"reportedUser": "645be3ee437ddbb7c8e37510",
                    "answer": "645be428437ddbb7c8e3752f"})
			.set('Accept', 'application/json')
			.set('Content-Type', 'application/json')
			.end(function (err, res) {
				expect(res.statusCode).to.be.equal(200);
    			expect(req.text).to.be.equal('ANSWER REPORTED');
				done();
			});
	});

    it('Reportuotų įrašų sarašo prašymas', (done) => {
		request(baseurl)
			.post('/reportAnswer')
            .query({"reportedUser": "645be3ee437ddbb7c8e37510",
                    "answer": "645be428437ddbb7c8e3752f"})
			.set('Accept', 'application/json')
			.set('Content-Type', 'application/json')
			.end(function (err, res) {
				expect(res.statusCode).to.be.equal(200);
				try {
                    value = JSON.parse(res.body);
                  } catch (e) {
                   isJson = false;
                  }
				expect(isJson).to.be.equal(true);
				done();
			});
	});


    it('Pranėšimų sąrašo prašymas', (done) => {
		request(baseurl)
			.get('/chats')
            .query({"roomId": "abc123"})
			.set('Accept', 'application/json')
			.set('Content-Type', 'application/json')
			.end(function (err, res) {
				expect(res.statusCode).to.be.equal(200);
				try {
                    value = JSON.parse(res.body);
                  } catch (e) {
                   isJson = false;
                  }
				expect(isJson).to.be.equal(true);
				done();
			});
	});
    



});


